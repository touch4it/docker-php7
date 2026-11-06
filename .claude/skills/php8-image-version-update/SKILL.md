---
name: php8-image-version-update
description: >-
  Check for and apply bugfix (patch-level) version updates to the touch4it/php8
  Docker images in the php8/ folder of the docker-php repo. Use this whenever the
  user asks to check, bump, refresh, or update PHP image versions, PHP patch
  versions, the base images, nginx, or Alpine/Debian bases for the php8 images —
  e.g. "are there newer PHP images?", "update the php8 dockerfiles", "bump nginx",
  "is our Alpine current?", "check Docker Hub for new PHP bugfix releases", "sync
  the php8 image versions". Trigger this even when the user doesn't name the
  skill, as long as they mean the php8/* image versions in this repo. It verifies
  every version against upstream sources (docker-library/php versions.json, the
  nginx docker-nginx stable Dockerfiles, Alpine's releases.json, and Docker Hub),
  then produces a change report.
---

# php8 image version update

Keep the `touch4it/php8` images in `php8/` current with upstream **bugfix
(patch) releases**. A bundled script finds and verifies every target; you
review the plan with the user, apply the edits, and write a report.

## Scope

In scope:
- **PHP patch bumps** within the existing minor (e.g. `8.4.20 → 8.4.22`). Each
  subfolder's PHP minor is fixed; this is bugfix maintenance, not `8.4 → 8.5`.
- **Base image follow-through:** adopt the newest Alpine minor / Debian codename
  that docker-library/php publishes for that PHP minor (e.g. `alpine3.23 →
  alpine3.24`, `bookworm → trixie`). These have more impact and are reported in
  their own section.
- **nginx patch bumps within the current stable minor** (e.g. `1.30.0 →
  1.30.3`), re-syncing `PKG_RELEASE`, `DYNPKG_RELEASE`, `KEY_SHA512`, and the
  recomputed `PKGOSSCHECKSUM`.
- **Alpine release check (report only).** For each Alpine-based image, the script
  identifies the Alpine patch actually inside `php:<tag>` and compares it with
  Alpine's own releases:
  - *patch drift*: e.g. the php image was built on Alpine 3.24.3, but 3.24.4 is out;
  - *minor drift*: Alpine's latest stable minor is newer than any `alpineX.YY`
    variant that docker-library/php publishes for that PHP minor;
  - *EOL*: the Alpine minor in use is past or near end-of-life.

  Our Dockerfiles can't fix any of these, because they only clear up when upstream
  rebuilds or adds a variant. Report them so the user knows how fresh the OS layer
  is, and don't edit anything for them.

Out of scope, so flag them and don't act: PHP minor/major bumps, nginx stable
**minor** bumps (e.g. `1.30 → 1.32`), anything in `php7/`, `symfony/` or
`drupal/`, adding images to `build.sh`, and building or pushing images
(`php8/build.sh` pushes to Docker Hub).

## Ground rules

- **Every version and checksum comes from a source, never from memory.** A wrong
  tag ships a broken or unintended image to every downstream consumer of
  `touch4it/php8`, so a plausible-looking value is worse than none. The script
  proves each tag exists on Docker Hub and recomputes the nginx checksum. If a
  source is unreachable or the script flags something, report it as not checked
  rather than filling the gap.
- **Stop for the user in two places only:**
  1. after presenting the plan, when it contains edits, to get approval;
  2. when a decision is genuinely the user's: upstream dropped the base you
     were on, a PHP minor vanished from `versions.json` (EOL), or a checksum
     disagrees with upstream.

  Everything else runs straight through. Once the user approves, apply the edits,
  re-run the check, and write the report in one pass, without pausing to
  summarise between steps. If the plan has no edits, skip the approval and go
  straight to the report.

## Workflow

### 1. Detect (read-only)

From the repo root:

```bash
python3 .claude/skills/php8-image-version-update/scripts/check_versions.py --repo .
```

The script reads every `php8/*/Dockerfile`, fetches the upstream sources, works
out and verifies each target, runs the Alpine check, and detects drift between
the Dockerfiles, `php8/build.sh` and the `-dev` pins. It prints the plan and edits
nothing. Add `--json` for a machine-readable changeset.

`NOT BUILT` in the drift section means a folder (currently
`php8.4-fpm-nginx-minimal`) has a Dockerfile but no tags in `build.sh`. Keep its
Dockerfile in sync like the others, and list it in the report so the user can
decide whether it should be built.

If a flag needs manual investigation, `references/sources.md` explains which
source backs each decision and how to query it by hand.

### 2. Present the plan

Show the plan using the report structure below, with base-image changes and flags
called out clearly. If it contains edits, wait for approval.

### 3. Apply

Edit the files by hand. The script never writes. `references/update-procedure.md`
gives the file-by-file recipe; read it before the first edit. Each change keeps
these in sync:

- the subfolder `Dockerfile` `FROM` line (and, for nginx, the `NGINX_VERSION` /
  `PKG_RELEASE` / `DYNPKG_RELEASE` / `KEY_SHA512` / `PKGOSSCHECKSUM` block);
- `php8/build.sh`: the patch tag in the `-t` build args **and** the matching
  `docker image push` line;
- the `-dev` Dockerfile `FROM touch4it/php8:phpX.Y.Z-fpm-nginx` pin;
- `README.md` lines that name a concrete version (e.g. the nginx version).

Then re-run step 1. A clean result (no changes, no `DRIFT`) is the check that
the edits are consistent.

### 4. Report

Write `version-update-report.md` in the repo root. In chat, give the outcome in
2–3 lines plus the report path; don't repeat the whole report. Recommend that
the user builds the affected images to confirm. Don't run `php8/build.sh` yourself.

## Report structure

Include only the sections that have content. A run with nothing to change is a
short report: a summary line, the Alpine status, and any flags.

```markdown
# php8 image version update — <YYYY-MM-DD>

## Summary
<N images checked, M changes applied, K flagged for review>

## PHP patch updates
- <subfolder> (<flavor>): PHP <old> → <new>
  - evidence: versions.json "<minor>".version = <new>; tag php:<new>-... verified 200

## Base image changes (higher impact — review carefully)
- <subfolder>: <alpine3.23 → alpine3.24 | bookworm → trixie>
  - evidence: newest <family> variant for <minor> in versions.json; tag verified 200

## nginx updates
- <subfolders>: nginx <old> → <new> (PKG_RELEASE <r>, DYNPKG_RELEASE <r>)
  - PKGOSSCHECKSUM <old8>… → <new8>… (recomputed locally, matches upstream)

## Alpine inside the php base images (report only)
- php:<tag> is built on Alpine <x.y.z>; newest Alpine <x.y> is <x.y.z'> (<date>) — <up to date | behind: not yet on Docker Hub | behind: php image not yet rebuilt>
- <minor drift / EOL notes, if any>

## Files changed
- <path>: <what changed>

## Flagged for manual review / skipped
- <subfolder/topic>: <reason>

## Pre-existing drift reconciled
- <e.g. php8.4-fpm-nginx-dev was pinned 8.4.17 while its Dockerfile was 8.4.20>

## Next steps
- Verify with: docker buildx build ./php8/<variant> -f ./php8/<variant>/Dockerfile --platform linux/amd64
```
