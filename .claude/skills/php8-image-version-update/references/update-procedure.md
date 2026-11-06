# Update procedure (per file)

Apply only the targets the plan from `check_versions.py` verified. Work through
one subfolder at a time so each change stays reviewable. The plan gives the
exact `old → new` values; this file shows where they live.

**The plan's target is the single source of truth.** If the plan reports drift
(`build.sh` or a `-dev` pin disagreeing with its Dockerfile), set every location
to the verified target so the drift is fixed in the same pass, rather than
keeping the old value.

## 1. Subfolder `Dockerfile` — `FROM` line

Replace the whole tag, PHP patch and base together, in one edit:

```
FROM php:8.4.20-fpm-alpine3.23      ->  FROM php:8.4.22-fpm-alpine3.24
FROM php:8.4.20-apache-bookworm     ->  FROM php:8.4.22-apache-trixie
```

The Apache and fpm-apache images reference the Debian release only through the
base image, so a base bump needs no other edit there. After a **base** change,
re-skim the Dockerfile for anything hard-coding the old base name.

## 2. nginx block (fpm-nginx Dockerfiles, including `-minimal`)

Update the pinned values from the plan:

```
ENV NGINX_VERSION=1.30.0     ->  ENV NGINX_VERSION=1.30.3
ENV PKG_RELEASE=1            ->  (only if upstream changed it)
ENV DYNPKG_RELEASE=1         ->  (only if upstream changed it)
KEY_SHA512="e09fa32…"        ->  (only if upstream changed it)
PKGOSSCHECKSUM=\"a090f4a…\"  ->  PKGOSSCHECKSUM=\"e602521…\"   (recomputed value)
```

`PKGOSSCHECKSUM` sits inside an escaped here-string. Replace only the hex
digest and leave the `\"` … ` *${NGINX_VERSION}-${PKG_RELEASE}.tar.gz\"` wrapper
intact. The same nginx values apply to every fpm-nginx subfolder.

## 3. `php8/build.sh` — tags *and* push lines

Each variant's `X.Y.Z` patch appears in two places, and both move to the target:

```
# build block
  -t touch4it/php8:php8.4.20-fpm-nginx \   ->  -t touch4it/php8:php8.4.22-fpm-nginx \
# push block
docker image push touch4it/php8:php8.4.20-fpm-nginx
                                          ->  …:php8.4.22-fpm-nginx
```

If the plan reports `DRIFT` for a variant, match on the current `build.sh`
string it shows, not the Dockerfile value. Floating tags (`php8.4-fpm-nginx`,
`php8-…`, `latest…`) carry no patch and stay as they are. Indent with 2 spaces
per `.editorconfig`, never tabs. Don't add `NOT BUILT` folders to `build.sh`;
that's the user's call.

## 4. `-dev` Dockerfile `FROM` pin

Each `php8.N-fpm-nginx-dev/Dockerfile` pins the prod image by exact patch:

```
FROM touch4it/php8:php8.4.20-fpm-nginx   ->  FROM touch4it/php8:php8.4.22-fpm-nginx
```

Set it to the prod image's target patch. The plan's "Dev image FROM pins to
re-sync" section lists these.

## 5. `README.md`

Edit only concrete version strings, such as the nginx version line near the
bottom. The tag lists use floating tags (e.g. `touch4it/php8:php8.4-fpm-nginx`),
which don't change on a patch bump.

## Base-image changes need extra care

A new Debian codename or Alpine minor is more than a bugfix, because package
names and default library versions can shift. When an Alpine fpm-nginx image's
base **and** nginx both bump, the build installs nginx from
`nginx.org/packages/alpine/v<alpine-minor>/`. Check that the nginx version is
published for the new Alpine minor, or flag it. When in doubt, suggest the user
build that image before pushing.
