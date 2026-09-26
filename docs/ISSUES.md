# Project Issues and Gaps

Reviewed on 2026-09-26 and updated after implementing `docs/PLAN.md`.

## Validation completed

- Actionlint, Yamllint, Rumdl, Hadolint, Just formatting, Ruff, and
  `git diff --check` pass locally.
- Caddy `2.11.4`, plugin versions, and all base image manifest digests were
  resolved from their upstream sources.
- A direct Xcaddy build completed, the resulting binary reported `v2.11.4` and
  both pinned module versions, the supported Caddyfile validated with it, and a
  local HTTP response smoke test passed.
- GitHub private vulnerability reporting is enabled and its exact reporting
  URL is documented.
- Existing GHCR tags and digests were recorded in `docs/RELEASING.md` before
  changing the release workflow.

Docker, Podman, Caddy, and the Quadlet generator are unavailable in the local
review environment. CI now contains the missing runtime validation, but that
workflow must run before the runtime dependent findings can be closed.

## Findings

### ISSUE-001 Release workflow paths and partial publication

**Status: resolved in configuration; workflow execution pending.**

The old main branch publish workflow was removed. Pull requests and main branch
pushes now run `.github/workflows/ci.yml` without registry write permission.
Only `.github/workflows/release.yml` publishes, after reusable CI succeeds.

### ISSUE-002 Image version and tag mismatch

**Status: resolved in configuration; image execution pending.**

`CADDY_VERSION` is the stored upstream version source. Every build receives it
as a build argument, while revisioned `vX.Y.Z-rN` tags identify image releases.
CI checks the binary, OCI labels, release tag, and image metadata independently.

### ISSUE-003 Invalid local publish recipes

**Status: resolved.**

The Justfile reads and validates `CADDY_VERSION` and only builds locally.
Registry publication is owned by the tag driven release workflow.

### ISSUE-004 Broken Compose example

**Status: repaired; Compose startup test pending CI.**

The example selects this project image, mounts the canonical supported
Caddyfile, uses named volumes, removes profiles and broad capabilities, and
loads a non-secret `.env.example`. CI validates and starts the Compose project.

### ISSUE-005 Unsupported Origin CA Caddyfile

**Status: resolved.**

The Origin CA example was removed because its required module is absent and its
certificate renewal limitation conflicts with a supported example.

### ISSUE-006 Missing pre-publish validation

**Status: implemented; first workflow run pending.**

CI now runs static checks, builds the image, checks its version and modules,
validates the supported Caddyfile, runs direct and Compose smoke tests, scans
the image, and verifies multi-platform builds before release can publish.

### ISSUE-007 Unpinned build inputs

**Status: resolved.**

The Cloudflare DNS and caddy-security modules are pinned to releases. Exact
runtime and builder image manifests are pinned for standard and Alpine tags.
Dependabot covers the root and example Dockerfile directories.

### ISSUE-008 Missing metadata and provenance

**Status: implemented; published artifact verification pending.**

Dockerfiles declare nonempty OCI metadata inputs. The release workflow consumes
generated labels and enables an SBOM and maximum BuildKit provenance. CI blocks
known fixed high and critical vulnerabilities in the tested image.

### ISSUE-009 Broad or conflicting deployment privileges

**Status: repaired; rootless and Quadlet runtime tests pending.**

Compose no longer grants `NET_ADMIN`. Quadlet uses bridge networking with
published ports, valid volume and network units, no hardcoded UID mappings, and
only `NET_BIND_SERVICE`. The rootless Dockerfile uses Xcaddy and numeric UID
443. CI tests its HTTP redirect, HTTPS listener, and writable Caddy state.

### ISSUE-010 Unusable security reporting path

**Status: resolved and verified.**

Private vulnerability reporting is enabled. `.github/SECURITY.md` links the
private report form and documents supported versions, response targets,
coordination, and security notice locations.

### ISSUE-011 Failing quality tools

**Status: resolved.**

All configured static checks pass through `just check`. Vale now checks the
maintained user documentation. Tool versions are pinned in `.mise.toml`.

### ISSUE-012 Incomplete user documentation

**Status: resolved in documentation; command execution pending CI.**

The README documents modules, architectures, tags, token permissions,
persistent storage, upgrade and rollback steps, and links every retained
example. CI covers the container and Compose commands.

### ISSUE-013 Inactive release maintenance

**Status: resolved.**

The disabled Release Please workflow and redundant major version file were
removed. A root changelog and `docs/RELEASING.md` define the revisioned,
tag-driven release lifecycle and digest based rollback.

### ISSUE-014 Confusing Docker build context

**Status: resolved.**

`.dockerignore` now contains one leading `*` rule and an explanation. The image
is assembled entirely from pinned upstream stages and copies no local context.

## Remaining acceptance work

- Run the new CI workflow on GitHub and confirm both architectures build.
- Validate the Quadlet units with a supported Podman generator and host.
- Publish one tag driven release, then verify tags, digest, SBOM, provenance,
  OCI labels, and installed modules from the registry artifact.
- Exercise one rollback to a recorded immutable digest.
