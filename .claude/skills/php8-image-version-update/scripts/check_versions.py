#!/usr/bin/env python3
"""
check_versions.py — read-only detector / planner for touch4it/php8 image updates.

Reads every php8/*/Dockerfile, resolves the authoritative upstream targets
(docker-library/php versions.json, nginx docker-nginx stable, Docker Hub tag API),
verifies every composed tag actually exists, recomputes the nginx pkg-oss
checksum, detects pre-existing drift across Dockerfiles / build.sh / -dev pins,
checks the Alpine patch/minor actually inside the php base images against
Alpine's own releases, and prints a complete plan plus a machine-readable
changeset.

Nothing is ever guessed: a target version is only proposed if its exact tag
returns HTTP 200 on Docker Hub (PHP) or its checksum recomputes to the published
value (nginx). When a source is unreachable or ambiguous the script flags it and
proposes no change.

The script is read-only and never edits files. Edits are applied by hand
following references/update-procedure.md, so each change stays reviewable.

Usage:
    python3 check_versions.py --repo /path/to/docker-php
    python3 check_versions.py --repo . --json        # also emit machine-readable JSON
"""

import argparse
import hashlib
import json
import os
import re
import sys
import urllib.request
import urllib.error

PHP_VERSIONS_URL = "https://raw.githubusercontent.com/docker-library/php/master/versions.json"
NGINX_SLIM_URL = "https://raw.githubusercontent.com/nginx/docker-nginx/master/stable/alpine-slim/Dockerfile"
HUB_TAG_URL = "https://hub.docker.com/v2/repositories/library/php/tags/{tag}"
PKGOSS_URL = "https://github.com/nginx/pkg-oss/archive/{ver}-{rel}.tar.gz"
ALPINE_RELEASES_URL = "https://alpinelinux.org/releases.json"
REGISTRY_TOKEN_URL = ("https://auth.docker.io/token?service=registry.docker.io"
                      "&scope=repository:{repo}:pull")
REGISTRY_MANIFEST_URL = "https://registry-1.docker.io/v2/{repo}/manifests/{ref}"
MANIFEST_ACCEPT = ",".join([
    "application/vnd.oci.image.index.v1+json",
    "application/vnd.docker.distribution.manifest.list.v2+json",
    "application/vnd.oci.image.manifest.v1+json",
    "application/vnd.docker.distribution.manifest.v2+json",
])
# Warn when the Alpine minor in use reaches end-of-life within this many days.
ALPINE_EOL_WARN_DAYS = 90

# Debian codename -> release number, so "newest" is unambiguous (no guessing by list order).
DEBIAN_SUITES = {
    "jessie": 8, "stretch": 9, "buster": 10, "bullseye": 11,
    "bookworm": 12, "trixie": 13, "forky": 14, "sid": 99,
}

UA = {"User-Agent": "php8-image-version-update/1.0"}


# --------------------------------------------------------------------------- #
# Fetch helpers
# --------------------------------------------------------------------------- #
def fetch_text(url, timeout=30):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read().decode("utf-8")


def fetch_json(url, timeout=30):
    return json.loads(fetch_text(url, timeout))


def hub_tag_exists(tag, timeout=30):
    """True iff library/php:<tag> exists on Docker Hub (HTTP 200)."""
    url = HUB_TAG_URL.format(tag=tag)
    req = urllib.request.Request(url, headers=UA, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status == 200
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return False
        raise


def recompute_pkgoss_sha512(ver, rel, timeout=120):
    """Download the pkg-oss tarball for <ver>-<rel> and return its sha512 hex."""
    url = PKGOSS_URL.format(ver=ver, rel=rel)
    req = urllib.request.Request(url, headers=UA)
    h = hashlib.sha512()
    with urllib.request.urlopen(req, timeout=timeout) as r:
        for chunk in iter(lambda: r.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


class Registry:
    """Anonymous Docker Hub registry client, used only to read amd64 layer digests."""

    def __init__(self, timeout=30):
        self.timeout = timeout
        self.tokens = {}
        self.layer_cache = {}

    def _token(self, repo):
        if repo not in self.tokens:
            self.tokens[repo] = fetch_json(REGISTRY_TOKEN_URL.format(repo=repo), self.timeout)["token"]
        return self.tokens[repo]

    def _manifest(self, repo, ref):
        req = urllib.request.Request(
            REGISTRY_MANIFEST_URL.format(repo=repo, ref=ref),
            headers={**UA, "Authorization": "Bearer " + self._token(repo), "Accept": MANIFEST_ACCEPT})
        with urllib.request.urlopen(req, timeout=self.timeout) as r:
            return json.loads(r.read().decode("utf-8"))

    def base_layer(self, repo, tag):
        """Digest of the bottom (rootfs) layer of repo:tag for linux/amd64, or None if the tag is absent."""
        key = (repo, tag)
        if key not in self.layer_cache:
            try:
                m = self._manifest(repo, tag)
                if "manifests" in m:
                    amd64 = [x for x in m["manifests"]
                             if x.get("platform", {}).get("os") == "linux"
                             and x["platform"].get("architecture") == "amd64"
                             and not x["platform"].get("variant")]
                    m = self._manifest(repo, amd64[0]["digest"]) if amd64 else {"layers": []}
                layers = m.get("layers") or []
                self.layer_cache[key] = layers[0]["digest"] if layers else None
            except urllib.error.HTTPError as e:
                if e.code != 404:
                    raise
                self.layer_cache[key] = None
        return self.layer_cache[key]


# --------------------------------------------------------------------------- #
# Version helpers
# --------------------------------------------------------------------------- #
def vtuple(v):
    return tuple(int(x) for x in re.findall(r"\d+", v))


def minor_of(v):
    p = v.split(".")
    return ".".join(p[:2])


def alpine_num(label):
    # "alpine3.23" -> (3, 23)
    return vtuple(label.replace("alpine", ""))


# --------------------------------------------------------------------------- #
# Dockerfile FROM parsing
# --------------------------------------------------------------------------- #
# Official base, e.g.:
#   FROM php:8.4.20-fpm-alpine3.23
#   FROM php:8.3.30-fpm-bookworm
OFFICIAL_RE = re.compile(
    r"^FROM\s+php:(?P<ver>\d+\.\d+\.\d+)-(?P<type>fpm|apache)-"
    r"(?:alpine(?P<alpine>[\d.]+)|(?P<suite>[a-z]+))\s*$"
)
# Internal -dev base, e.g.:  FROM touch4it/php8:php8.4.17-fpm-nginx
DEV_RE = re.compile(
    r"^FROM\s+touch4it/php8:php(?P<ver>\d+\.\d+\.\d+)-(?P<variant>\S+)\s*$"
)


def read_from_line(dockerfile):
    with open(dockerfile, encoding="utf-8") as f:
        for line in f:
            if line.startswith("FROM"):
                return line.rstrip("\n")
    return None


# --------------------------------------------------------------------------- #
# Core resolution
# --------------------------------------------------------------------------- #
def resolve_official(folder, ver, typ, alpine, suite, versions, cache):
    """Return a dict describing the proposed change (or no-op / flag) for an
    official-base image."""
    minor = minor_of(ver)
    out = {
        "folder": folder, "kind": "official", "type": typ,
        "current_ver": ver, "current_base": f"alpine{alpine}" if alpine else suite,
        "changes": [], "flags": [], "target_ver": ver,
        "target_base": f"alpine{alpine}" if alpine else suite,
    }

    vj = versions.get(minor)
    if not vj:
        out["flags"].append(
            f"PHP {minor} is not present in docker-library/php versions.json "
            f"(likely end-of-life) — no automated bump; review manually."
        )
        return out

    target_ver = vj["version"]
    variants = vj.get("variants", [])

    # newest base of the same family the official image publishes for this minor
    if alpine is not None:
        cands = [v.split("/")[0] for v in variants
                 if v.endswith(f"/{typ}") and v.startswith("alpine")]
        if not cands:
            out["flags"].append(f"No alpine '{typ}' variant for {minor} in versions.json.")
            return out
        target_base = max(cands, key=alpine_num)
    else:
        cands = [v.split("/")[0] for v in variants
                 if v.endswith(f"/{typ}") and v.split("/")[0] in DEBIAN_SUITES]
        if not cands:
            out["flags"].append(f"No debian '{typ}' variant for {minor} in versions.json.")
            return out
        target_base = max(cands, key=lambda s: DEBIAN_SUITES[s])

    out["target_ver"] = target_ver
    out["target_base"] = target_base

    # compose the exact tag and PROVE it exists before proposing anything
    if alpine is not None:
        tag = f"{target_ver}-{typ}-{target_base}"
    else:
        tag = f"{target_ver}-{typ}-{target_base}"
    cache_key = tag
    if cache_key not in cache:
        cache[cache_key] = hub_tag_exists(tag)
    if not cache[cache_key]:
        out["flags"].append(
            f"Computed target tag php:{tag} does NOT exist on Docker Hub — refusing "
            f"to propose it (no guessing). Investigate upstream."
        )
        return out
    out["verified_tag"] = f"php:{tag}"

    if vtuple(target_ver) > vtuple(ver):
        out["changes"].append(("php", ver, target_ver))
    elif vtuple(target_ver) < vtuple(ver):
        out["flags"].append(
            f"Local {ver} is NEWER than versions.json {target_ver} — unexpected; review."
        )

    cur_base = f"alpine{alpine}" if alpine else suite
    if target_base != cur_base:
        out["changes"].append(("base", cur_base, target_base))

    return out


def resolve_nginx(folders_versions, timeout=120):
    """Resolve the nginx target from the stable alpine-slim Dockerfile.
    folders_versions: list of (folder, current_nginx_version)."""
    txt = fetch_text(NGINX_SLIM_URL)
    def envval(name):
        m = re.search(rf"^ENV\s+{name}\s+(\S+)", txt, re.M)
        return m.group(1) if m else None
    up_ver = envval("NGINX_VERSION")
    up_pkg = envval("PKG_RELEASE")
    up_dyn = envval("DYNPKG_RELEASE")
    mkey = re.search(r'KEY_SHA512="([0-9a-f]+)"', txt)
    up_key = mkey.group(1) if mkey else None
    mpub = re.search(r'PKGOSSCHECKSUM=\\"([0-9a-f]+)', txt)
    up_pkgoss_published = mpub.group(1) if mpub else None

    result = {
        "upstream_ver": up_ver, "pkg_release": up_pkg, "dynpkg_release": up_dyn,
        "key_sha512": up_key, "pkgoss_published": up_pkgoss_published,
        "pkgoss_recomputed": None, "per_folder": [], "flags": [], "apply": False,
    }
    if not up_ver:
        result["flags"].append("Could not read NGINX_VERSION from upstream stable Dockerfile.")
        return result

    # current minor across our images (assume consistent; report any outlier)
    cur_versions = {v for _, v in folders_versions}
    for folder, cur in folders_versions:
        if minor_of(cur) != minor_of(up_ver):
            result["per_folder"].append((folder, cur, None,
                f"nginx stable is now {up_ver} (minor {minor_of(up_ver)}); ours is "
                f"{cur} (minor {minor_of(cur)}). Minor bump is OUT OF SCOPE — flagged."))
        elif vtuple(up_ver) > vtuple(cur):
            result["per_folder"].append((folder, cur, up_ver, "patch bump"))
        else:
            result["per_folder"].append((folder, cur, cur, "up to date"))

    needs_bump = any(t and t != c for _, c, t, _ in result["per_folder"])
    if needs_bump:
        # recompute the pkg-oss checksum deterministically and cross-check upstream
        try:
            recomputed = recompute_pkgoss_sha512(up_ver, up_pkg, timeout=timeout)
        except Exception as e:  # noqa: BLE001
            result["flags"].append(f"Could not recompute pkg-oss checksum: {e}")
            return result
        result["pkgoss_recomputed"] = recomputed
        if up_pkgoss_published and recomputed != up_pkgoss_published:
            result["flags"].append(
                f"Recomputed pkg-oss checksum ({recomputed[:12]}…) does NOT match "
                f"upstream published value ({up_pkgoss_published[:12]}…) — refusing to "
                f"apply nginx update (no guessing). Investigate.")
        else:
            result["apply"] = True
    return result


# --------------------------------------------------------------------------- #
# Drift detection across files
# --------------------------------------------------------------------------- #
def resolve_alpine(official_results, timeout=30):
    """Report-only check of the Alpine release *inside* each Alpine php base image.

    Two kinds of drift, neither fixable by editing our Dockerfiles:
      * patch: the php image was built on e.g. Alpine 3.24.3 while Alpine has
        released 3.24.4 (the php image has not been rebuilt yet);
      * minor: Alpine's latest stable minor is newer than the newest alpineX.YY
        variant docker-library/php publishes for that PHP minor.
    The patch actually inside the image is proven by matching the php image's
    amd64 rootfs layer digest against alpine:<patch> tags — never inferred.
    """
    import datetime

    imgs = [r for r in official_results if r["target_base"].startswith("alpine")]
    if not imgs:
        return None
    rel = fetch_json(ALPINE_RELEASES_URL, timeout)
    latest_stable = rel.get("latest_stable", "").lstrip("v")  # "3.24"
    branches = {b["rel_branch"].lstrip("v"): b for b in rel.get("release_branches", [])
                if b.get("rel_branch", "").startswith("v")}
    reg = Registry(timeout)
    today = datetime.date.today()
    out = {"latest_stable": latest_stable, "per_image": [], "flags": []}

    for r in imgs:
        minor = r["target_base"][len("alpine"):]
        tag = (r.get("verified_tag") or
               f"php:{r['current_ver']}-{r['type']}-{r['current_base']}")[len("php:"):]
        row = {"folder": r["folder"], "php_tag": f"php:{tag}", "alpine_minor": minor,
               "in_image": None, "newest_patch": None, "newest_date": None,
               "newest_on_hub": None, "status": "", "eol_date": None}
        br = branches.get(minor)
        if not br or not br.get("releases"):
            row["status"] = f"Alpine v{minor} not found in releases.json — cannot check"
            out["per_image"].append(row)
            continue
        releases = sorted(br["releases"], key=lambda x: vtuple(x["version"]), reverse=True)
        newest = releases[0]
        row["newest_patch"], row["newest_date"] = newest["version"], newest.get("date")
        row["eol_date"] = br.get("eol_date")

        php_layer = reg.base_layer("library/php", tag)
        if php_layer is None:
            row["status"] = f"php:{tag} manifest not readable — cannot check"
            out["per_image"].append(row)
            continue
        for rr in releases:
            if reg.base_layer("library/alpine", rr["version"]) == php_layer:
                row["in_image"] = rr["version"]
                break
        row["newest_on_hub"] = reg.base_layer("library/alpine", newest["version"]) is not None

        if row["in_image"] is None:
            row["status"] = (f"base layer matches no alpine:{minor}.x tag — Alpine patch "
                             f"inside the image is unknown (not guessed)")
        elif row["in_image"] == newest["version"]:
            row["status"] = "up to date"
        else:
            hub = ("alpine image already published, php image not yet rebuilt"
                   if row["newest_on_hub"] else "not yet published as alpine image on Docker Hub")
            row["status"] = (f"BEHIND — built on {row['in_image']}, Alpine {newest['version']} "
                             f"released {newest.get('date', '?')} ({hub})")
        out["per_image"].append(row)

        if row["eol_date"]:
            try:
                eol = datetime.date.fromisoformat(row["eol_date"])
                days = (eol - today).days
                if days <= ALPINE_EOL_WARN_DAYS:
                    out["flags"].append(
                        f"{r['folder']}: Alpine v{minor} "
                        f"{'reached' if days < 0 else 'reaches'} end-of-life on {row['eol_date']}.")
            except ValueError:
                pass

        if latest_stable and vtuple(latest_stable) > vtuple(minor):
            out["flags"].append(
                f"{r['folder']}: Alpine v{latest_stable} is the latest stable, but docker-library/php "
                f"publishes at most alpine{minor} for PHP {minor_of(r['target_ver'])} — "
                f"nothing to apply until upstream adds it.")
    return out


def find_buildsh_patch(buildsh_text, variant):
    """Return the patch version currently tagged for a variant in build.sh,
    e.g. variant='php8.4-fpm-nginx' -> '8.4.17' from
    'touch4it/php8:php8.4.17-fpm-nginx'. None if not found. The tag must end
    there, so 'php8.4-fpm-nginx' does not match '...-fpm-nginx-dev'."""
    minor, flavor = variant[len("php"):].split("-", 1)  # '8.4', 'fpm-nginx'
    m = re.search(rf"touch4it/php8:php({re.escape(minor)}\.\d+)-{re.escape(flavor)}(?=[\s\\]|$)",
                  buildsh_text, re.M)
    return m.group(1) if m else None


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo", default=".", help="path to docker-php repo root")
    ap.add_argument("--plan", action="store_true",
                    help="accepted for compatibility; the script is always read-only")
    ap.add_argument("--json", action="store_true", help="also emit machine-readable JSON")
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    php8 = os.path.join(repo, "php8")
    if not os.path.isdir(php8):
        sys.exit(f"error: {php8} not found (is --repo the docker-php root?)")

    print("Fetching authoritative sources …", file=sys.stderr)
    versions = fetch_json(PHP_VERSIONS_URL)

    folders = sorted(d for d in os.listdir(php8)
                     if os.path.isdir(os.path.join(php8, d)) and d.startswith("php8."))

    hub_cache = {}
    official_results = []
    dev_pins = {}       # folder -> (ver, variant)
    nginx_folders = []  # (folder, nginx_version)

    for folder in folders:
        df = os.path.join(php8, folder, "Dockerfile")
        if not os.path.isfile(df):
            continue
        frm = read_from_line(df)
        if frm is None:
            continue
        mo = OFFICIAL_RE.match(frm)
        if mo:
            res = resolve_official(
                folder, mo["ver"], mo["type"], mo["alpine"], mo["suite"],
                versions, hub_cache)
            official_results.append(res)
            # collect nginx version if present
            with open(df, encoding="utf-8") as f:
                dtxt = f.read()
            mn = re.search(r"^ENV NGINX_VERSION=(\S+)", dtxt, re.M)
            if mn:
                nginx_folders.append((folder, mn.group(1)))
            continue
        md = DEV_RE.match(frm)
        if md:
            dev_pins[folder] = (md["ver"], md["variant"])
            continue

    nginx = resolve_nginx(nginx_folders) if nginx_folders else None
    try:
        alpine = resolve_alpine(official_results)
    except (urllib.error.URLError, KeyError, ValueError) as e:
        alpine = {"error": f"Alpine check failed ({e}) — report it as not checked, do not guess."}

    # ----- render plan -----
    print(f"\n{'='*72}\nphp8 image version update — PLAN (read-only)\n{'='*72}")
    n_changes = 0
    for r in official_results:
        if r["changes"]:
            n_changes += 1
            print(f"\n[{r['folder']}]  ({r['type']})")
            for kind, old, new in r["changes"]:
                label = "PHP patch" if kind == "php" else "BASE IMAGE"
                print(f"   {label:10} {old} -> {new}")
            if r.get("verified_tag"):
                print(f"   verified:  {r['verified_tag']} (Docker Hub 200)")
        for fl in r["flags"]:
            print(f"\n[{r['folder']}]  FLAG: {fl}")

    if nginx:
        print(f"\n{'-'*72}\nnginx (stable line)\n{'-'*72}")
        print(f"   upstream stable NGINX_VERSION = {nginx['upstream_ver']} "
              f"(PKG_RELEASE {nginx['pkg_release']}, DYNPKG_RELEASE {nginx['dynpkg_release']})")
        for folder, cur, tgt, note in nginx["per_folder"]:
            arrow = f"{cur} -> {tgt}" if tgt and tgt != cur else f"{cur} (no change)"
            print(f"   {folder:28} {arrow:18} {note}")
        if nginx["pkgoss_recomputed"]:
            match = "matches upstream" if nginx["apply"] else "MISMATCH — blocked"
            print(f"   PKGOSSCHECKSUM recomputed: {nginx['pkgoss_recomputed'][:16]}… ({match})")
            print(f"   KEY_SHA512 (upstream):     {nginx['key_sha512'][:16]}…")
        for fl in nginx["flags"]:
            print(f"   FLAG: {fl}")

    if alpine:
        print(f"\n{'-'*72}\nAlpine inside the php base images (report only — nothing to edit)\n{'-'*72}")
        if "error" in alpine:
            print(f"   FLAG: {alpine['error']}")
        else:
            print(f"   Alpine latest stable = v{alpine['latest_stable']}")
            for row in alpine["per_image"]:
                inside = row["in_image"] or "?"
                print(f"   {row['folder']:28} {row['php_tag']:30} Alpine {inside:8} {row['status']}")
            for fl in alpine["flags"]:
                print(f"   FLAG: {fl}")

    # ----- drift detection -----
    print(f"\n{'-'*72}\nConsistency / pre-existing drift\n{'-'*72}")
    buildsh = os.path.join(php8, "build.sh")
    buildsh_text = open(buildsh, encoding="utf-8").read() if os.path.isfile(buildsh) else ""
    by_folder = {r["folder"]: r for r in official_results}
    drift = []
    for folder in folders:
        r = by_folder.get(folder)
        cur = r["current_ver"] if r else (dev_pins[folder][0] if folder in dev_pins else None)
        if cur is None:
            continue
        bp = find_buildsh_patch(buildsh_text, folder)
        if bp is None:
            drift.append(f"   NOT BUILT  {folder}: no patch tag in php8/build.sh — its Dockerfile "
                         f"is checked and may be bumped, but build.sh never builds or pushes it")
        elif bp != cur:
            drift.append(f"   DRIFT  {folder}: Dockerfile {cur} but build.sh tags {bp}")
    for devf, (dver, variant) in sorted(dev_pins.items()):
        prod = f"php{minor_of(dver)}-{variant}"  # 8.4.17 + fpm-nginx -> php8.4-fpm-nginx
        pr = by_folder.get(prod)
        if pr and dver != pr["current_ver"]:
            drift.append(f"   DRIFT  {devf}: pins {dver} but {prod} Dockerfile is {pr['current_ver']}")
    print("\n".join(drift) if drift else "   none")

    # ----- dev pin re-sync targets (each -dev FROM follows its prod image's target) -----
    dev_lines = []
    for devf, (dver, variant) in sorted(dev_pins.items()):
        prod = f"php{minor_of(dver)}-{variant}"
        pr = by_folder.get(prod)
        if not pr:
            continue
        target = pr["target_ver"]
        if dver != target:
            dev_lines.append(f"   {devf:28} FROM …:php{dver}-{variant} -> php{target}-{variant}")
    if dev_lines:
        print(f"\n{'-'*72}\nDev image FROM pins to re-sync (follow prod target)\n{'-'*72}")
        print("\n".join(dev_lines))

    print(f"\n{'='*72}\n{n_changes} image(s) with PHP/base changes; "
          f"nginx {'update available' if nginx and nginx['apply'] else 'no in-scope change'}.")
    print("Read-only: apply edits by hand per references/update-procedure.md.")
    print(f"{'='*72}")

    if args.json:
        print("\nJSON_CHANGESET:" + json.dumps({
            "official": official_results, "nginx": nginx, "alpine": alpine,
            "dev_pins": dev_pins,
        }, default=str))


if __name__ == "__main__":
    main()
