[![CI](https://github.com/thimslugga/caddy-cloudflare/actions/workflows/ci.yml/badge.svg)](https://github.com/thimslugga/caddy-cloudflare/actions/workflows/ci.yml)

# Caddy Cloudflare

A multi-architecture Caddy container image with these pinned modules:

- [Cloudflare DNS](https://github.com/caddy-dns/cloudflare) `v0.2.4`
- [caddy-security](https://github.com/greenpau/caddy-security) `v1.2.2`

The current image builds Caddy `2.11.4` for `linux/amd64` and `linux/arm64`.

## Image tags

Releases publish the following tags to
`ghcr.io/thimslugga/caddy-cloudflare`:

- `X.Y.Z-rN`: immutable image release
- `X.Y.Z`: latest validated image revision for one Caddy release
- `X.Y`: latest patch in a minor release line
- `X`: latest release in a major release line
- `latest`: latest validated release

Use an `X.Y.Z-rN` tag or image digest when deployments must not change without
an explicit update. The revision suffix permits plugin, base image, and
security updates without overwriting an existing release. Alpine and rootless
Dockerfiles are tested examples and are not published as supported tags.

## Quick start

Create a Caddyfile:

```caddyfile
example.com {
  tls {
    dns cloudflare {env.CF_API_TOKEN}
  }
  respond "Caddy Cloudflare is running"
}
```

Create an environment file containing a Cloudflare API token:

```dotenv
CF_API_TOKEN=replace-with-a-scoped-cloudflare-api-token
```

Start Caddy with persistent data and configuration volumes:

```shell
docker volume create caddy-data
docker volume create caddy-config
docker run --detach \
  --name caddy \
  --env-file .env \
  --publish 80:80/tcp \
  --publish 443:443/tcp \
  --publish 443:443/udp \
  --volume "${PWD}/Caddyfile:/etc/caddy/Caddyfile:ro" \
  --volume caddy-data:/data \
  --volume caddy-config:/config \
  ghcr.io/thimslugga/caddy-cloudflare:2.11.4-r1
```

Keep `/data` during upgrades because it stores certificates and other Caddy
state. Back up the Caddyfile, environment file, `/data`, and `/config` before a
change.

## Cloudflare token permissions

Create a Cloudflare API token limited to the zones Caddy manages. Grant `Zone`
`DNS` `Edit` and `Zone` `Zone` `Read`. The supported configuration variable is
`CF_API_TOKEN`. Do not commit the token or place it directly in a Caddyfile.

## Examples

- [Caddyfile](docs/examples/caddy/README.md)
- [Compose](docs/examples/compose/README.md)
- [Dockerfiles](docs/examples/dockerfile/README.md)
- [Podman Quadlet](docs/examples/quadlet/README.md)

## Build locally

Install the versions in `.mise.toml`, then run the checks and build:

```shell
mise install
just check
just build
```

`just build` does not push an image. A matching revisioned release tag in
GitHub Actions is the only path that publishes an immutable image or updates
stable and `latest` tags.

## Upgrade and rollback

Update `CADDY_VERSION`, plugin pins, and base image digests together, then follow
[the release procedure](docs/RELEASING.md). Validate the new release before
removing the old container.

To roll back, replace the image reference with the previous `X.Y.Z-rN` tag or
digest and recreate the container. Restore the matching Caddyfile and data
backup when an upgrade changed stored state or configuration.

## Security

Report vulnerabilities through the private process in
[the security policy](.github/SECURITY.md).

## License

See [LICENSE](LICENSE).
