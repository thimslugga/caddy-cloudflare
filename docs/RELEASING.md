# Release procedure

Signed Git tags are the release authority. `CADDY_VERSION` contains the
upstream Caddy version used in the project image. Release tags add an image
revision in the form `vX.Y.Z-rN`; the workflow creates the corresponding GitHub
Release after publication succeeds.

## Prepare a release

1. Run `scripts/get-latest-caddy-release.py` and choose the target stable Caddy
   release.
2. Update `CADDY_VERSION`.
3. Resolve and update the Cloudflare DNS and caddy-security module versions in
   every Dockerfile.
4. Resolve each exact Caddy runtime and builder tag to its multi-architecture
   manifest digest and update the matching Dockerfile argument.
5. Choose the image revision. Use `r1` for a new Caddy version and increment the
   revision for plugin, base image, or project changes that retain the same
   Caddy version.
6. Update documented image versions and `.env.example` files.
7. Add the release notes to `CHANGELOG.md`.
8. Run `mise install`, `just check`, and `just build`.
9. Open a pull request and require the CI workflow to pass.

The release pull request must keep the Caddy binary version aligned with
`CADDY_VERSION`. The OCI image version and immutable image tag must match the
revisioned Git tag without its leading `v`.

## Publish a release

After merging the release pull request:

```shell
caddy_version="$(<CADDY_VERSION)"
revision=1
release_tag="v${caddy_version}-r${revision}"
git tag --sign "${release_tag}" --message "Release ${release_tag}"
git push origin "${release_tag}"
```

Set `revision` to the selected release revision. The release workflow validates
the Caddy portion of the tag against `CADDY_VERSION`, reruns CI, and publishes
the immutable `X.Y.Z-rN` image for `linux/amd64` and `linux/arm64`. After the
image passes its vulnerability scan, the workflow updates `X.Y.Z`, `X.Y`, `X`,
and `latest`, attaches an SBOM and provenance, and creates the GitHub Release.

Verify the registry digest and generated GitHub Release notes contain:

- Caddy and plugin versions
- immutable image tag and digest
- supported platforms
- changes and known limitations

## Roll back

Redeploy the previous `X.Y.Z-rN` tag or digest first. If mutable tags must be
restored, retag the previous validated digest in the registry. Do not rebuild
historical source as part of a rollback.

Before this release process was introduced, the registry contained:

| Tags | Digest |
| --- | --- |
| `2.8.4`, `latest` | `sha256:ef7fe39afc216c8414fe3cc2fb770bc0a134a734e5654427f30e9ff78c1ffc03` |
| `2.8.4-alpine`, `latest-alpine` | `sha256:4263e6fc5e19d72f65b0136d2809f90abbe4aeb23e5204a49ab90c28549509d0` |

These digests are rollback records, not supported current versions.
