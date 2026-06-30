# Update procedure (per file)

Apply only the targets the plan from `check_versions.py` verified. Work one
subfolder at a time so each change stays reviewable, and keep all four sync
targets consistent. The plan already tells you the exact `old → new` values; this
file tells you *where* they live and how to reconcile pre-existing drift.

A guiding principle for drift: **the plan's target is the single source of truth.**
Where `build.sh` or a `-dev` pin currently disagrees with its Dockerfile (drift),
do not preserve the old value — set every location to the verified target so the
drift is healed in the same pass.

## 1. Subfolder `Dockerfile` — `FROM` line

Replace the whole tag, both PHP patch and base, in one edit:

```
FROM php:8.4.20-fpm-alpine3.23      ->  FROM php:8.4.22-fpm-alpine3.24
FROM php:8.4.20-apache-bookworm     ->  FROM php:8.4.22-apache-trixie
```

Apache/fpm-apache images additionally reference the Debian release in package
steps only implicitly (via the base) — no other line needs editing for a base
bump there. Re-skim the Dockerfile after a **base** change for anything that
hard-codes the old base name (rare, but check).

## 2. nginx block (fpm-nginx Dockerfiles only)

For each fpm-nginx image getting a nginx bump, update the pinned values from the
plan (sourced per `references/sources.md`). They appear as:

```
ENV NGINX_VERSION=1.30.0     ->  ENV NGINX_VERSION=1.30.3
ENV PKG_RELEASE=1            ->  (only if upstream changed it)
ENV DYNPKG_RELEASE=1         ->  (only if upstream changed it)
KEY_SHA512="e09fa32…"        ->  (only if upstream changed it)
PKGOSSCHECKSUM=\"a090f4a…\"  ->  PKGOSSCHECKSUM=\"e602521…\"   (recomputed value)
```

The `PKGOSSCHECKSUM` line is inside an escaped here-string; replace only the hex
digest, leaving the `\"` … ` *${NGINX_VERSION}-${PKG_RELEASE}.tar.gz\"` wrapper
intact. The same nginx values apply to **all** fpm-nginx subfolders on the same
stable line — update each one.

## 3. `php8/build.sh` — tags *and* push lines

For each affected variant, every `X.Y.Z` patch occurs in **two** places that must
both move to the target:

```
# build block
-t touch4it/php8:php8.4.17-fpm-nginx \   ->  -t touch4it/php8:php8.4.22-fpm-nginx \
# push block
docker image push touch4it/php8:php8.4.17-fpm-nginx
                                          ->  …:php8.4.22-fpm-nginx
```

Note the existing **drift**: some build.sh patches (e.g. `8.4.17`) already lag
their Dockerfile (`8.4.20`). Match on the *current build.sh string* (what the plan
reports under "pre-existing drift"), not the Dockerfile value, then set it to the
target (`8.4.22`). The minor/`latest`/`php8`/`php8-fpm-nginx` floating tags do not
carry a patch and stay as-is.

## 4. `-dev` Dockerfile `FROM` pin

Each `php8.N-fpm-nginx-dev/Dockerfile` pins the prod image by exact patch:

```
FROM touch4it/php8:php8.4.17-fpm-nginx   ->  FROM touch4it/php8:php8.4.22-fpm-nginx
```

Set it to the prod image's **target** patch (the plan's "Dev image FROM pins to
re-sync" section lists these explicitly). This also heals any dev-vs-prod drift.

## 5. `README.md`

Update version references that name a concrete version:
- the nginx version line near the bottom (`## What Nginx version …` → `1.30.3`),
- any explicit patch versions in the image/tag lists.

The README mostly lists *floating* tags (e.g. `touch4it/php8:php8.4-fpm-nginx`),
which don't change on a patch bump — only edit concrete version strings.

## After applying

1. Re-run the plan; it should now report **no changes and no drift**:
   ```bash
   python3 .claude/skills/php8-image-version-update/scripts/check_versions.py --repo . --plan
   ```
   A clean re-run is the verification that the edits are internally consistent.
2. Write `version-update-report.md` (see the report template in `SKILL.md`).
3. Recommend (do **not** run) a build to validate the images actually build:
   `docker build ./php8/php8.4-fpm-nginx -f ./php8/php8.4-fpm-nginx/Dockerfile --platform linux/amd64`
   or the full `sh php8/build.sh` (which also pushes — the user runs that, not
   the skill).

## Base-image changes — extra care

Adopting a new Debian codename (`bookworm → trixie`) or Alpine minor
(`alpine3.23 → alpine3.24`) is more than a bugfix: package names/availability and
default library versions can shift. The plan separates these under "BASE IMAGE".
Call them out distinctly in the report and, when in doubt, suggest the user build
that specific image to confirm before pushing.
