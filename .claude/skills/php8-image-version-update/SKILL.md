---
name: php8-image-version-update
description: >-
  Check for and apply bugfix (patch-level) version updates to the touch4it/php8
  Docker images in the php8/ folder of the docker-php repo. Use this whenever the
  user asks to check, bump, refresh, or update PHP image versions, PHP patch
  versions, the base images, nginx, or Alpine/Debian bases for the php8 images —
  e.g. "are there newer PHP images?", "update the php8 dockerfiles", "bump nginx",
  "check Docker Hub for new PHP bugfix releases", "sync the php8 image versions".
  Trigger this even when the user doesn't name the skill, as long as they mean the
  php8/* image versions in this repo. It verifies every version against
  authoritative upstream sources (docker-library/php versions.json, the nginx
  docker-nginx stable Dockerfiles, and the Docker Hub tag API) so no version is
  ever guessed, then produces a change report.
---

# php8 image version update

Keep the `touch4it/php8` images in `php8/` current with upstream **bugfix
(patch) releases**, without ever guessing a version. Every proposed version is
proven against an authoritative source before it is written, and a report of all
changes is produced.

## Scope (what this skill does and does NOT do)

In scope:
- **PHP patch bumps** within the existing minor (e.g. `8.4.20 → 8.4.22`). The PHP
  minor of each subfolder is fixed — this is bugfix maintenance, not `8.4 → 8.5`.
- **Base image** follow-through: adopt the newest Alpine minor / Debian codename
  that docker-library/php publishes for that PHP minor (e.g. `alpine3.23 →
  alpine3.24`, `bookworm → trixie`). Base changes are higher-impact and are
  reported separately.
- **nginx patch bumps within the current stable minor only** (e.g. `1.30.0 →
  1.30.3`), re-syncing `PKG_RELEASE`, `DYNPKG_RELEASE`, `KEY_SHA512`, and
  recomputing `PKGOSSCHECKSUM`. A stable **minor** jump (e.g. `1.30 → 1.32`) is
  out of scope — flag it, never apply it.

Out of scope (flag for the user, do not act):
- PHP minor/major bumps, nginx stable minor bumps, anything in `php7/`,
  `symfony/`, or `drupal/`, and building/pushing images.

## Core rules (non-negotiable)

These exist because a wrong tag silently ships a broken or unintended image to
every downstream consumer of `touch4it/php8`.

1. **Never guess a version or checksum.** Every value comes from an authoritative
   source and, for image tags, is confirmed to exist on Docker Hub (HTTP 200)
   before it is written. If a source is unreachable or ambiguous, stop and report
   — do not fill the gap with a plausible-looking value.
2. **Plan before execution.** Always produce the full plan first and let the user
   review it before any file is edited. The detection step is read-only.
3. **Always produce a report** of what changed (and what was skipped and why),
   even when nothing changed.
4. **Ask when genuinely uncertain** — e.g. upstream dropped the base you were on,
   a minor was removed from `versions.json` (EOL), or a checksum recompute
   disagrees with upstream's published value.

## Workflow

### 1. Detect (read-only) — run the detection script

```bash
python3 .claude/skills/php8-image-version-update/scripts/check_versions.py \
  --repo . --plan
```

It reads every `php8/*/Dockerfile`, fetches the authoritative sources, computes
each target, verifies the composed tags on Docker Hub, recomputes the nginx
checksum, detects pre-existing drift between the Dockerfiles / `build.sh` /
`-dev` pins / `README.md`, and prints a complete plan plus a machine-readable
changeset. It does **not** edit anything.

Read `references/sources.md` to understand exactly which source backs each
decision and how certainty is established.

### 2. Present the plan

Show the user the plan from step 1. Organize it with the **Report structure**
below. Make sure base-image changes and anything flagged are clearly called out —
those carry the most risk. Wait for the user to approve before editing.

### 3. Apply — edit the four sync targets

Once approved, apply the changeset. Either let the script apply the mechanical
replacements:

```bash
python3 .claude/skills/php8-image-version-update/scripts/check_versions.py \
  --repo . --apply
```

…or apply the listed `path / old → new` replacements yourself with the editor
when a case needs judgment. Every change must keep these four in sync:

- the subfolder **`Dockerfile` `FROM`** line (and, for nginx, the `NGINX_VERSION`
  / `PKG_RELEASE` / `DYNPKG_RELEASE` / `KEY_SHA512` / `PKGOSSCHECKSUM` block),
- **`php8/build.sh`** — every `X.Y.Z` patch tag in the `-t` build args **and** the
  matching `docker image push` lines for that variant,
- the **`-dev` Dockerfile** `FROM touch4it/php8:phpX.Y.Z-fpm-nginx` pin,
- **`README.md`** version references (e.g. the nginx version line, tag lists).

`references/update-procedure.md` has the exact, file-by-file edit recipe
(including how to reconcile pre-existing drift, where `build.sh` or a `-dev` pin
already disagrees with its Dockerfile). Read it before editing.

### 4. Report

Write `version-update-report.md` in the repo root using the structure below, and
summarize it in chat. Do **not** build or push images — recommend the user run
the relevant `docker build` / `php8/build.sh` to verify.

## Report structure

Use this template (omit empty sections only if there is truly nothing for them):

```markdown
# php8 image version update — <YYYY-MM-DD>

## Summary
<N images checked, M changes applied, K flagged for review, E errors>

## PHP patch updates
- <subfolder> (<flavor>): PHP <old> → <new>
  - evidence: versions.json "<minor>".version = <new>; tag php:<new>-... verified 200

## Base image changes (higher impact — review carefully)
- <subfolder>: <alpine3.23 → alpine3.24 | bookworm → trixie>
  - evidence: newest <family> variant for <minor> in versions.json; tag verified 200

## nginx updates
- <subfolder...>: nginx <old> → <new> (PKG_RELEASE <r>, DYNPKG_RELEASE <r>)
  - PKGOSSCHECKSUM <old8>… → <new8>… (recomputed locally, matches upstream)

## Files changed
- <path>: <what changed>

## Flagged for manual review / skipped
- <subfolder/topic>: <reason> (e.g. nginx stable moved to 1.32 minor; PHP 8.1 EOL/absent from versions.json)

## Pre-existing drift reconciled
- <e.g. php8.4-fpm-nginx-dev was pinned 8.4.17 while its Dockerfile was 8.4.20>

## Next steps
- Verify with: <docker build … | sh php8/build.sh> (not run by this skill)
```

## Key references
- `references/sources.md` — authoritative URLs, the exact `jq`/API queries, the
  Docker Hub tag-existence check, the nginx checksum recompute, and the
  Debian-codename / Alpine-minor ordering used to pick the "newest" base.
- `references/update-procedure.md` — the precise per-file edit procedure and how
  drift is reconciled.
- `scripts/check_versions.py` — the read-only detector / planner (and `--apply`
  for the mechanical replacements).
