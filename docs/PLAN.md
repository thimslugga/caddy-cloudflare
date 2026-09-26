# Remediation Plan

This plan resolves the findings in `docs/ISSUES.md` in dependency order. The
first goal is a deterministic local build, followed by pull request validation,
safe publication, and reliable examples and documentation.

Checked items are implemented in the working tree. The final acceptance items
remain open until CI, a Podman host, or an actual release supplies runtime
evidence.

## Working decisions

- Use `docs/examples/dockerfile/` as the canonical directory for the moved
  example Dockerfiles, matching `AGENTS.md`.
- Keep the root `Dockerfile` as the primary release image definition.
- Treat files under `docs/examples/` as tested examples, not release inputs.
- Use `CADDY_VERSION` as the only stored upstream Caddy version value.
- Use revisioned Git tags as the image release version; do not store derived
  major, minor, or image release values in additional files.
- Publish images from version tags, after validation, instead of every push to
  `main`.
- Do not publish a separate Alpine tag unless its image is materially different
  from the primary image and has an explicit support contract.
- Prefer the standard library and existing repository tools over new project
  dependencies.

## Phase 0 Prevent incorrect publication

Goal: prevent the current workflow and local recipes from pushing mislabeled or
partially built images while repairs are in progress.

- [x] Disable automatic pushes from `main` in
  `.github/workflows/build-push.yml`.
- [x] Remove `workflow_dispatch` from the retired publish workflow; manual local
  builds remain build-only by default.
- [x] Remove `--push` from the default Just recipes.
- [x] Remove local registry publishing so the release workflow is the only
  publication path.
- [x] Record the currently published tags and digests before changing release
  behavior.

Exit criteria:

- No routine command or branch push can update `latest`.
- A maintainer must intentionally create and push a signed release tag.

Addresses: ISSUE-001, ISSUE-002, ISSUE-003, ISSUE-006.

## Phase 1 Normalize layout and build inputs

Goal: make every build path point to an intentional, canonical file.

- [x] Rename `docs/examples/docker/` to `docs/examples/dockerfile/`.
- [x] Update repository documentation and checks to use the canonical path.
- [x] Remove root paths for the moved variant Dockerfiles from workflow path
  filters and build commands.
- [x] Decide the supported release variants:
  - Primary recommendation: publish only the root `Dockerfile` image.
  - Validate the Alpine and rootless Dockerfiles as examples without publishing
    their tags.
  - If a variant becomes a supported artifact, move its Dockerfile to a
    dedicated production directory before adding it to the publish workflow.
- [x] Remove `latest-alpine` recipes and workflow steps if the Alpine variant is
  not a supported artifact.
- [x] Simplify `.dockerignore` to the leading `*` rule plus a short explanation,
  because the root build uses no local context files.

Exit criteria:

- All path references resolve.
- `rg 'Dockerfile\.alpine|Dockerfile\.rootless'` shows only intentional example
  or validation references.
- Production inputs are not stored under an examples directory.

Addresses: ISSUE-001, ISSUE-003, ISSUE-014.

## Phase 2 Make builds deterministic

Goal: ensure a requested version always produces the same identifiable image.

### Version flow

- [x] Update `CADDY_VERSION` to the selected stable Caddy release.
- [x] Remove hardcoded Caddy versions from Dockerfiles and deployment examples.
- [x] Require `CADDY_VERSION` as a Docker build argument.
- [x] Make the Justfile read and validate `CADDY_VERSION` once.
- [x] Pass `CADDY_VERSION` and a distinct `IMAGE_VERSION` build argument from
  local and CI builds.
- [x] Derive major and minor tags from `CADDY_VERSION`; remove `MAJOR_VERSION`
  unless another consumer needs it.
- [x] Add a check that rejects malformed versions and mismatches between the Git
  tag, `CADDY_VERSION`, revisioned image tag, OCI labels, and `caddy version`
  output.
- [x] Use `scripts/get-latest-caddy-release.py` for update detection, not as an
  implicit mutation during a release.

### Dependency pins

- [x] Resolve stable versions or commits for:
  - `github.com/caddy-dns/cloudflare`
  - `github.com/greenpau/caddy-security`
- [x] Change each Xcaddy argument to `module@version`.
- [x] Pin release base images by multi-architecture manifest digest.
- [x] Document the update procedure for Caddy, plugins, and base image digests.
- [x] Extend dependency automation to inspect the example Dockerfile directory.

### OCI metadata

- [x] Declare build arguments for creation time, source revision, version, and
  source URL.
- [x] Supply the values from CI and local release recipes.
- [x] Use `SOURCE_DATE_EPOCH` or the source commit time when reproducibility is
  required.
- [x] Confirm the final image contains nonempty standard OCI labels.

Exit criteria:

- Two builds from the same commit and inputs resolve the same source versions.
- The binary version, image tag, and OCI version label agree.
- `caddy build-info` contains both pinned module versions.

Addresses: ISSUE-002, ISSUE-003, ISSUE-007, ISSUE-008, ISSUE-013.

## Phase 3 Repair local quality gates

Goal: make every configured static check usable before adding it to CI.

- [x] Remove the unsupported `require-starting-space` option from the Yamllint
  `key-ordering` rule.
- [x] Adjust the Yamllint truthy rule for GitHub Actions syntax without allowing
  ambiguous values in ordinary YAML files.
- [x] Remove the empty workflow matrix.
- [x] Quote `"$GITHUB_ENV"` and address every Actionlint finding.
- [x] Format the Justfile with `just --fmt` and review the resulting diff.
- [x] Fix the existing Rumdl findings, including the broken reference in
  `.github/CONTRIBUTING.md`.
- [x] Replace the named rootless `USER` with a numeric UID, or document and
  narrowly ignore Hadolint `DL3066` if name lookup is required.
- [x] Configure Vale as an enforced documentation check and remove the unused
  Git Cliff configuration.
- [x] Add a single `just check` recipe that runs all non-container checks.

Required commands:

```shell
actionlint -color=false .github/workflows/*.yml
yamllint -f parsable .
rumdl check . --color never --exclude "docs/styles/**"
hadolint Dockerfile docs/examples/dockerfile/Dockerfile*
just --fmt --check
uv sync --frozen
uv run --frozen --no-sync ruff check .
uv run --frozen --no-sync ruff format --check .
uv run --frozen --no-sync ty check scripts/get-latest-caddy-release.py
uv run --frozen --no-sync mypy scripts/get-latest-caddy-release.py
uv run --frozen --no-sync pytest
vale sync
vale README.md CHANGELOG.md .github/CONTRIBUTING.md .github/SECURITY.md docs/DEVELOPMENT.md docs/RELEASING.md docs/examples
```

Exit criteria:

- Every required command exits successfully from a clean checkout.
- No configured linter is empty or inert.

Addresses: ISSUE-011, ISSUE-013.

## Phase 4 Add build and runtime validation

Goal: prove the image contains the expected binary and can load supported
configuration before anything is published.

### Pull request workflow

- [x] Add a pull request workflow for relevant Dockerfiles, scripts, examples,
  tool configuration, and workflow files.
- [x] Run `just check` first.
- [x] Build a local `linux/amd64` image without pushing.
- [x] Inspect `caddy version` and fail on a `CADDY_VERSION` mismatch.
- [x] Inspect `caddy build-info` and require the pinned Cloudflare and security
  modules.
- [x] Run `caddy validate` or `caddy adapt` against every supported Caddyfile.
- [x] Start the image with a minimal test configuration and verify an HTTP
  response.
- [x] Build the multi-architecture manifest without publishing it.

### Release workflow

- [x] Trigger releases only from a `vX.Y.Z-rN` Git tag whose Caddy portion
  matches `CADDY_VERSION`.
- [x] Reuse the same validation jobs as pull requests.
- [x] Generate tags and labels with `docker/metadata-action` and consume its
  outputs.
- [x] Build all release platforms before updating any mutable tag.
- [x] Publish immutable `X.Y.Z-rN` first, then `X.Y.Z`, `X.Y`, `X`, and `latest`
  after all checks pass.
- [x] Generate an SBOM and provenance attestation for the pushed digest.
- [x] Scan the immutable release digest and block mutable tags on the agreed
  severity policy.
- [x] Reduce workflow permissions to the minimum needed by each job.
- [x] Pin third-party GitHub Actions to full commit hashes.

Exit criteria:

- Pull requests cannot publish images.
- A failing variant or smoke test leaves existing registry tags unchanged.
- A released digest has version evidence, an SBOM, and provenance.

Addresses: ISSUE-001, ISSUE-002, ISSUE-006, ISSUE-007, ISSUE-008.

## Phase 5 Repair and test deployment examples

Goal: make each documented example runnable as copied.

### Compose

- [x] Select
  `ghcr.io/thimslugga/caddy-cloudflare:${CADDY_IMAGE_VERSION}` or build the
  project image from a valid context.
- [x] Place a supported Caddyfile beside the Compose file or mount the correct
  canonical relative path.
- [x] Use named volumes consistently for `/data` and `/config`.
- [x] Remove profiles unless the accompanying instructions require them.
- [x] Load the Cloudflare token from an environment file or secret and provide a
  non-secret `.env.example`.
- [x] Remove `NET_ADMIN`; add only the capability proven necessary by the chosen
  user and port model.
- [x] Run `docker compose config` and a startup smoke test in CI.

### Caddyfiles

- [x] Standardize the DNS token variable name across supported examples.
- [x] Remove `Caddyfile.example` from the supported set by default because it
  requires the absent Cloudflare Origin CA issuer module.
- [x] Remove the Origin CA example instead of maintaining a separate image with
  an unsupported renewal limitation.
- [x] Validate all supported Caddyfiles with the actual project image.

### Rootless image

- [x] Replace deprecated `caddy-builder` usage with `xcaddy build`.
- [x] Confirm the numeric runtime UID can access `/data`, `/config`, and the
  Caddyfile.
- [x] Confirm the copied binary retains the capability needed for low ports, or
  use unprivileged container ports.
- [x] Start the image as non-root in CI and verify HTTP and HTTPS listeners.

### Quadlet

- [x] Choose bridge networking with `PublishPort` or host networking without
  published ports.
- [x] Replace hardcoded host paths and UID mappings with documented values.
- [x] Create valid network units or remove the empty network files.
- [ ] Validate generated systemd units on a supported Podman host.

Exit criteria:

- Each retained example has a documented command that succeeds from its own
  directory.
- Supported examples are validated in CI against the image they name.
- Examples grant no capability that their documented configuration does not
  require.

Addresses: ISSUE-004, ISSUE-005, ISSUE-009, ISSUE-012.

## Phase 6 Complete user and security documentation

Goal: make image behavior, support, and reporting paths clear.

### README

- [x] Point the badge to the actual validation or release workflow.
- [x] Name every included Caddy module and its pinned version.
- [x] Document supported architectures and image tags.
- [x] Add a tested quick start with `/data` and `/config` persistence.
- [x] Publish TCP 80, TCP 443, and UDP 443 in the recommended invocation.
- [x] Explain Cloudflare token scope and environment variable names.
- [x] Link the Dockerfile, Compose, Caddyfile, and Quadlet examples.
- [x] Document upgrades, rollback by immutable tag or digest, and configuration
  backup expectations.

### Security policy

- [x] Enable GitHub private vulnerability reporting or choose a monitored
  security email address.
- [x] Put the exact private reporting link or address in
  `.github/SECURITY.md`.
- [x] State supported image versions, response expectations, disclosure flow,
  and where security notices are published.

Exit criteria:

- Every README command is covered by an automated or recorded manual test.
- A reporter can submit a vulnerability privately using the documented path.

Addresses: ISSUE-010, ISSUE-012.

## Phase 7 Define the release lifecycle

Goal: make releases intentional, traceable, and recoverable.

- [x] Use signed Git tags as the release authority and create the corresponding
  GitHub Release after publication.
- [x] Restore a root `CHANGELOG.md` and update it as part of each release pull
  request.
- [x] Remove the disabled Release Please workflow and empty Git Cliff
  configuration unless one is deliberately adopted and configured.
- [x] Define the release sequence:
  - Update `CADDY_VERSION` and dependency pins in a pull request.
  - Pass all static, build, example, and security checks.
  - Merge the release pull request.
  - Create the matching signed `vX.Y.Z-rN` tag.
  - Let CI publish and attest the image.
  - Verify registry tags and digests.
  - Publish release notes containing the Caddy version, plugin versions, image
    digest, supported platforms, and known limitations.
- [x] Document rollback by restoring mutable tags to the previous validated
  digest without rebuilding it.

Exit criteria:

- One documented mechanism owns image release tags and changelog maintenance.
- Every GitHub release maps to one source tag and immutable image digest.
- A rollback does not require rebuilding historical source.

Addresses: ISSUE-002, ISSUE-008, ISSUE-013.

## Final acceptance checklist

- [ ] All P0 findings in `docs/ISSUES.md` are closed.
- [ ] All static checks pass from a clean checkout.
- [ ] Primary and supported variant images build for `linux/amd64` and
  `linux/arm64`.
- [ ] Binary version and required modules are verified inside each image.
- [ ] Every retained Caddyfile, Compose file, and Quadlet unit is validated.
- [ ] Pull requests build and test without registry write permission.
- [ ] Releases publish only from matching version tags.
- [ ] Published digests have an SBOM, scan result, and provenance attestation.
- [ ] README and security reporting instructions are current and tested.
- [ ] The release and rollback procedures have been exercised once.

## Issue traceability

| Issue | Primary phases | Completion evidence |
| --- | --- | --- |
| ISSUE-001 | 0, 1, 4 | All workflow paths resolve; no partial publish |
| ISSUE-002 | 0, 2, 4, 7 | Version, tag, label, and binary agree |
| ISSUE-003 | 0, 1, 2 | Local builds never publish; releases use valid tags |
| ISSUE-004 | 5 | Compose config and startup test pass |
| ISSUE-005 | 5 | Unsupported example removed or dedicated image tested |
| ISSUE-006 | 0, 4 | Pull request and release validation workflows pass |
| ISSUE-007 | 2, 4 | Plugin versions and image inputs are pinned |
| ISSUE-008 | 2, 4, 7 | Labels, SBOM, scan, and provenance exist |
| ISSUE-009 | 5 | Least-privilege examples pass runtime tests |
| ISSUE-010 | 6 | Private reporting path is usable |
| ISSUE-011 | 3 | All configured quality tools pass |
| ISSUE-012 | 5, 6 | Tested README and linked examples |
| ISSUE-013 | 2, 3, 7 | One version and release mechanism remains |
| ISSUE-014 | 1 | Docker context policy is minimal and explicit |
