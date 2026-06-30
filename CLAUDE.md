# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A monorepo of **Dockerfiles** (not application code) that produce the `touch4it/*` PHP base images published to Docker Hub. Each leaf directory is one image variant: a `Dockerfile` plus its supporting config files. There is no application source, no test suite, and no CI config in the repo — the "build" is `docker build` + `docker push`.

## Build & publish

`build.sh` scripts both build **and push** images (they call `docker image push` at the end), so running them publishes to Docker Hub. Be deliberate — don't run them just to verify a Dockerfile compiles.

- Root `./build.sh` → builds `php8/` then `drupal/` (does **not** include `php7/` or `symfony/`, which are legacy and built via their own scripts).
- `php8/build.sh`, `drupal/build.sh`, `symfony/build.sh`, `php7/build.sh` → per-family build+push.
- All builds use `--platform linux/amd64`.

To build a single image without pushing (the common dev case), run docker directly from the family dir, e.g.:

```bash
cd php8 && docker build ./php8.4-fpm-nginx -t test:local -f ./php8.4-fpm-nginx/Dockerfile --platform linux/amd64
```

To smoke-test: `docker run --rm -p 8080:80 test:local` then hit `localhost:8080`.

## Image matrix

Three runtime flavors, repeated per PHP version:

| Flavor | Base | Web server | Dirs |
|--------|------|-----------|------|
| `*-apache` | Debian (`php:X-apache-*`) | Apache + mod_php | `php8.N-apache` |
| `*-fpm-apache` | Debian (`php:X-fpm-*`) | Apache proxying to PHP-FPM | `php8.N-fpm-apache` |
| `*-fpm-nginx` | Alpine (`php:X-fpm-alpine*`) | Nginx + PHP-FPM | `php8.N-fpm-nginx` |

`drupal/` and `symfony/` are framework images layered **on top of** the `touch4it/php8` / php7 nginx-fpm bases (`FROM touch4it/php8:...`), adding the framework, Composer plugins, and (Drupal) drush/drupal-console.

## Key architectural conventions

- **Config is mounted into known paths** by every Dockerfile via `COPY`:
  - `docker-vars.ini` → `$PHP_INI_DIR/conf.d/` — PHP runtime settings (the main knob).
  - `www.conf` → php-fpm pool config (fpm flavors).
  - `nginx.conf` + `nginx.vh.default.conf` → nginx (nginx flavor).
  - `000-default.conf` + `php-override.ini` → Apache (apache flavors).
- **PHP settings are env-var driven.** `docker-vars.ini` references `${PHP_TIME_ZONE}`, `${PHP_MEMORY_LIMIT}`, `${PHP_UPLOAD_MAX_FILESIZE}`, `${PHP_POST_MAX_SIZE}`, defaulted via `ENV` in the Dockerfile and overridable at `docker run`. Apache images also use `ADMIN_EMAIL`.
- **`-dev` images are thin overlays.** Their Dockerfile is just `FROM touch4it/php8:<prod-tag>` + a `COPY docker-vars.ini`. The dev `docker-vars.ini` flips production hardening off: `opcache.enable = 0`, `display_errors = On`, `expose_php = On`, longer `max_execution_time`. Edit the dev variant's ini, not the Dockerfile, for dev-only behavior.
- **Production `docker-vars.ini` is security-hardened**: `display_errors = Off`, `allow_url_include = Off`, and a `disable_functions` blacklist (`exec`, `shell_exec`, `system`, `proc_open`, `popen`, etc.). Changing this list affects every consumer of the image.
- **The entrypoint runs multiple processes** (no init system). nginx: `entrypoint.sh` backgrounds `php-fpm` and `crond`, foregrounds `nginx`. apache: backgrounds `php-fpm` + `cron`, foregrounds `apache2-foreground`. `STOPSIGNAL SIGQUIT` for graceful shutdown.
- **Imagick install differs by base**: Alpine fpm-nginx 8.4/8.5 use **PIE** (`pie install imagick/...`); older and Debian/Apache images build imagick from the PECL source tarball with a pinned version. Bundled PHP extensions (bcmath, gd, intl, pdo_mysql/pgsql, zip, etc.) go through `docker-php-ext-install`.

## Bumping versions (the most common change)

A PHP/nginx/framework version bump is **not** a single-file edit. To bump, e.g., a PHP patch version you must update in lockstep:

1. The `FROM php:X.Y.Z-...` line in the variant's `Dockerfile`.
2. Every `-t touch4it/...:X.Y.Z-...` tag for that variant in the family `build.sh` (both the build block **and** the matching `docker push` block).
3. The version list in the relevant `README.md` (e.g. nginx version is stated at the bottom of the root `README.md`).
4. For `-dev` images: the `FROM touch4it/php8:X.Y.Z-...` pin in the dev Dockerfile.

Nginx version is pinned via `ENV NGINX_VERSION` plus checksum/signing-key values inside the fpm-nginx Dockerfiles — bumping nginx means updating those checksums too.

## Style

`.editorconfig`: LF, final newline. Indent — 2 spaces for Dockerfiles, **tabs (width 4)** for `*.conf` files, 2 spaces otherwise.
