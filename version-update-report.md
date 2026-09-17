# php8 image version update — 2026-09-17

## Summary
6 images checked with PHP/base changes, 5 nginx bugfix targets, 13 files changed, 0 errors. One pre-existing uncommitted drift issue in `build.sh` was flagged and resolved per user direction before applying the bump.

## PHP patch updates
- php8.2-apache (apache): PHP 8.2.31 → 8.2.33
  - evidence: versions.json "8.2".version = 8.2.33; tag php:8.2.33-apache-trixie verified 200
- php8.2-fpm-apache (fpm): PHP 8.2.31 → 8.2.33
  - evidence: tag php:8.2.33-fpm-trixie verified 200
- php8.2-fpm-nginx (fpm): PHP 8.2.31 → 8.2.33
  - evidence: tag php:8.2.33-fpm-alpine3.24 verified 200
- php8.5-apache (apache): PHP 8.5.7 → 8.5.10
  - evidence: versions.json "8.5".version = 8.5.10; tag php:8.5.10-apache-trixie verified 200
- php8.5-fpm-apache (fpm): PHP 8.5.7 → 8.5.10
  - evidence: tag php:8.5.10-fpm-trixie verified 200
- php8.5-fpm-nginx (fpm): PHP 8.5.7 → 8.5.10
  - evidence: tag php:8.5.10-fpm-alpine3.24 verified 200

PHP 8.3 (8.3.33) and PHP 8.4 (8.4.25) were already at the latest published patch — no change needed.

## Base image changes (higher impact — review carefully)
None. All affected images were already on the newest base for their PHP minor (Debian trixie / Alpine 3.24).

## nginx updates
- php8.2-fpm-nginx, php8.3-fpm-nginx, php8.4-fpm-nginx, php8.4-fpm-nginx-minimal, php8.5-fpm-nginx: nginx 1.30.3 → 1.30.5 (PKG_RELEASE 1, DYNPKG_RELEASE 1 — unchanged)
  - PKGOSSCHECKSUM e602521342632b9c… → feaa7c9e587e59a0… (recomputed locally, matches upstream published value)
  - KEY_SHA512 unchanged (e09fa32f0a0eab2b…, upstream still matches)

## Files changed
- php8/php8.2-apache/Dockerfile: FROM php:8.2.31-apache-trixie → php:8.2.33-apache-trixie
- php8/php8.2-fpm-apache/Dockerfile: FROM php:8.2.31-fpm-trixie → php:8.2.33-fpm-trixie
- php8/php8.2-fpm-nginx/Dockerfile: FROM php:8.2.31-fpm-alpine3.24 → php:8.2.33-fpm-alpine3.24; NGINX_VERSION 1.30.3 → 1.30.5; PKGOSSCHECKSUM updated
- php8/php8.5-apache/Dockerfile: FROM php:8.5.7-apache-trixie → php:8.5.10-apache-trixie
- php8/php8.5-fpm-apache/Dockerfile: FROM php:8.5.7-fpm-trixie → php:8.5.10-fpm-trixie
- php8/php8.5-fpm-nginx/Dockerfile: FROM php:8.5.7-fpm-alpine3.24 → php:8.5.10-fpm-alpine3.24; NGINX_VERSION 1.30.3 → 1.30.5; PKGOSSCHECKSUM updated
- php8/php8.3-fpm-nginx/Dockerfile: NGINX_VERSION 1.30.3 → 1.30.5; PKGOSSCHECKSUM updated (no PHP change)
- php8/php8.4-fpm-nginx/Dockerfile: NGINX_VERSION 1.30.3 → 1.30.5; PKGOSSCHECKSUM updated (no PHP change)
- php8/php8.4-fpm-nginx-minimal/Dockerfile: NGINX_VERSION 1.30.3 → 1.30.5; PKGOSSCHECKSUM updated (no PHP change)
- php8/php8.2-fpm-nginx-dev/Dockerfile: FROM touch4it/php8:php8.2.31-fpm-nginx → php8.2.33-fpm-nginx
- php8/php8.5-fpm-nginx-dev/Dockerfile: FROM touch4it/php8:php8.5.7-fpm-nginx → php8.5.10-fpm-nginx
- php8/build.sh: all `-t` build tags and matching `docker image push` lines for php8.2-apache, php8.2-fpm-apache, php8.2-fpm-nginx, php8.2-fpm-nginx-dev, php8.5-apache, php8.5-fpm-apache, php8.5-fpm-nginx, php8.5-fpm-nginx-dev updated to the new patch versions
- README.md: "What Nginx version is on Nginx-based images?" 1.30.3 → 1.30.5

## Flagged for manual review / skipped
None outstanding — see "Pre-existing drift reconciled" below for an issue that came in via the working tree and was resolved before the bump was applied.

## Pre-existing drift reconciled
- Before this run, `php8/build.sh` had an **uncommitted, unstaged edit** (unrelated to this skill) that commented out every `docker image push` line and incorrectly changed the PHP 8.3 tag on the push lines from `8.3.33` to `8.3.31`, while the `-t` build lines and Dockerfiles correctly stayed at `8.3.33`. Per your direction, this was treated as unintended: `git restore php8/build.sh` reverted it to the committed state (pushes uncommented, `8.3.33` consistent) before the 8.2/8.5/nginx bump was layered on top.

## Next steps
- Verify with: `cd php8 && docker build ./php8.2-apache -t test:local -f ./php8.2-apache/Dockerfile --platform linux/amd64` (repeat for php8.2-fpm-apache, php8.2-fpm-nginx, php8.2-fpm-nginx-dev, php8.5-apache, php8.5-fpm-apache, php8.5-fpm-nginx, php8.5-fpm-nginx-dev, and any php8.3/8.4-fpm-nginx variant to confirm the nginx bump alone still builds).
- Not run by this skill: `sh php8/build.sh` (builds **and pushes** all images to Docker Hub) — run it yourself once you're satisfied with local builds.
