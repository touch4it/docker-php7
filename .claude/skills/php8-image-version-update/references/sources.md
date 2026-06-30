# Authoritative sources & certainty gates

The whole point of this skill is that **no version or checksum is ever guessed**.
Each decision traces to one of these sources, and image tags are confirmed to
exist before being written. If a source is unreachable or disagrees with a
cross-check, stop and flag — do not substitute a plausible value.

## PHP version & base images — docker-library/php `versions.json`

Raw URL (the canonical, machine-readable source the official images are built
from):

```
https://raw.githubusercontent.com/docker-library/php/master/versions.json
```

Per PHP minor it gives the current patch and the published variants:

```bash
curl -fsSL <url> | jq '."8.4" | {version, variants}'
# version  -> "8.4.22"      (the latest bugfix for 8.4)
# variants -> ["trixie/fpm","bookworm/fpm","alpine3.24/fpm","alpine3.23/fpm", ...]
```

- **Target PHP patch** = `."<minor>".version`.
- **Target base** = the *newest* variant of the same family and type the image
  uses:
  - Alpine fpm-nginx images use `-fpm-alpine<minor>` → pick the highest
    `alpineX.YY` among `*/fpm` variants.
  - Debian apache images use `-apache-<suite>` → pick the highest-ranked `<suite>`
    among `*/apache` variants. fpm-apache images use `-fpm-<suite>` → `*/fpm`.
- **Minor absent from `versions.json`** (e.g. PHP 8.1 after EOL) → propose no PHP
  bump; flag for manual review. Never invent a "latest 8.1".

### Ordering (so "newest" is deterministic, not list-order luck)

- Alpine: numeric compare on `(major, minor)` of `alpineX.YY`.
- Debian codename → release number:
  `bullseye=11, bookworm=12, trixie=13, forky=14, sid=99` (extend as Debian adds
  releases). Higher = newer.

## Tag existence — Docker Hub tag API (the final certainty gate)

Before writing any `FROM php:<tag>`, confirm `<tag>` actually exists:

```bash
curl -s -o /dev/null -w "%{http_code}" \
  "https://hub.docker.com/v2/repositories/library/php/tags/8.4.22-fpm-alpine3.24"
# 200 = exists (safe to write) ; 404 = does NOT exist (refuse, flag)
```

`versions.json` says what *should* be published; this proves it *is*. Both must
agree.

## nginx — docker-nginx stable Dockerfiles

The fpm-nginx images embed a from-source nginx build (pkg-oss path). The
authoritative pins live in the **stable `alpine-slim`** Dockerfile:

```
https://raw.githubusercontent.com/nginx/docker-nginx/master/stable/alpine-slim/Dockerfile
```

Read exact values:
- `ENV NGINX_VERSION   1.30.3`   → target nginx version (note: the sibling
  `stable/alpine/Dockerfile` carries it on its `FROM nginx:<ver>-alpine-slim`
  line; both agree).
- `ENV PKG_RELEASE     1`
- `ENV DYNPKG_RELEASE  1`
- `KEY_SHA512="e09fa32…"`        → nginx signing-key checksum (rarely changes).
- `PKGOSSCHECKSUM=\"e602521…\""  → upstream's published pkg-oss tarball checksum.

### Scope gate (patch within current stable minor only)

Compare `NGINX_VERSION` minor to our current `ENV NGINX_VERSION` in the
Dockerfiles:
- **Same minor, newer patch** (e.g. `1.30.0` → `1.30.3`) → in scope.
- **Different minor** (e.g. stable moved to `1.32`) → OUT OF SCOPE. Flag it,
  apply nothing.

### Checksum — recompute, never copy blindly

Download the exact pkg-oss tarball and recompute, then cross-check against the
upstream published value:

```bash
curl -fsSL -o /tmp/pkgoss.tgz \
  "https://github.com/nginx/pkg-oss/archive/1.30.3-1.tar.gz"
openssl sha512 -r /tmp/pkgoss.tgz | awk '{print $1}'
# must equal PKGOSSCHECKSUM from stable/alpine-slim — if it differs, STOP.
```

`check_versions.py` does this recompute-and-compare automatically and refuses to
propose the nginx change on mismatch.

### Base ↔ nginx interaction (important)

When an Alpine fpm-nginx image's base bumps (e.g. `alpine3.23 → alpine3.24`) *and*
nginx bumps, the embedded build installs nginx from `nginx.org/packages/alpine/v<alpine-minor>/`.
Confirm the new nginx version is published for the **new** Alpine minor before
trusting the build (the pkg-oss checksum itself is Alpine-independent, but apk
package availability is not). If unsure, flag it rather than assume.
