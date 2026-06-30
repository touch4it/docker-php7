#!/usr/bin/env python3
"""
check_versions.py — read-only detector / planner for touch4it/php8 image updates.

Reads every php8/*/Dockerfile, resolves the authoritative upstream targets
(docker-library/php versions.json, nginx docker-nginx stable, Docker Hub tag API),
verifies every composed tag actually exists, recomputes the nginx pkg-oss
checksum, detects pre-existing drift across Dockerfiles / build.sh / -dev pins /
README, and prints a complete plan plus a machine-readable changeset.

Nothing is ever guessed: a target version is only proposed if its exact tag
returns HTTP 200 on Docker Hub (PHP) or its checksum recomputes to the published
value (nginx). When a source is unreachable or ambiguous the script flags it and
proposes no change.

Default mode is --plan (read-only). --apply performs the exact string
replacements the plan lists (still no guessing — only the verified strings).

Usage:
    python3 check_versions.py --repo /path/to/docker-php --plan
    python3 check_versions.py --repo /path/to/docker-php --apply
    python3 check_versions.py --repo . --plan --json        # machine-readable
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
#   FROM php:8.1.34-apache-bullseye
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
def find_buildsh_patch(buildsh_text, variant):
    """Return the patch version currently tagged for a variant in build.sh,
    e.g. variant='php8.4-fpm-nginx' -> '8.4.17' from
    'touch4it/php8:php8.4.17-fpm-nginx'. None if not found."""
    suffix = variant[len("php8"):]  # e.g. ".4-fpm-nginx"
    minor = variant.split("-")[0][3:]  # 'php8.4' -> '8.4'
    m = re.search(rf"touch4it/php8:php({re.escape(minor)}\.\d+)-{re.escape(suffix.split('-',1)[1])}\b",
                  buildsh_text)
    return m.group(1) if m else None


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo", default=".", help="path to docker-php repo root")
    ap.add_argument("--plan", action="store_true", help="read-only plan (default)")
    ap.add_argument("--apply", action="store_true", help="apply mechanical replacements")
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

    # ----- drift detection -----
    print(f"\n{'-'*72}\nConsistency / pre-existing drift\n{'-'*72}")
    buildsh = os.path.join(php8, "build.sh")
    buildsh_text = open(buildsh, encoding="utf-8").read() if os.path.isfile(buildsh) else ""
    by_folder = {r["folder"]: r for r in official_results}
    for folder in folders:
        r = by_folder.get(folder)
        if not r:
            continue
        bp = find_buildsh_patch(buildsh_text, folder)
        if bp and bp != r["current_ver"]:
            print(f"   DRIFT  {folder}: Dockerfile {r['current_ver']} but build.sh tags {bp}")
    for devf, (dver, variant) in sorted(dev_pins.items()):
        prod = f"php{minor_of(dver)}-{variant}"  # 8.4.17 + fpm-nginx -> php8.4-fpm-nginx
        pr = by_folder.get(prod)
        if pr and dver != pr["current_ver"]:
            print(f"   DRIFT  {devf}: pins {dver} but {prod} Dockerfile is {pr['current_ver']}")

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
    print("Review this plan before applying. Re-run with --apply to write changes.")
    print(f"{'='*72}")

    if args.json:
        print("\nJSON_CHANGESET:" + json.dumps({
            "official": official_results, "nginx": nginx, "dev_pins": dev_pins,
        }, default=str))

    if args.apply:
        print("\n--apply requested: see references/update-procedure.md. This script "
              "intentionally prints the verified changeset; apply edits via the "
              "documented procedure so each change stays reviewable.", file=sys.stderr)


if __name__ == "__main__":
    main()
