# caddy-cloudflare

Caddy container image(s) with Cloudflare DNS plugin included.

## Status

[![caddy-cloudflare OCI build](https://github.com/thimslugga/caddy-cloudflare/actions/workflows/oci-build.yml/badge.svg)](https://github.com/thimslugga/caddy-cloudflare/actions/workflows/oci-build.yml)

## Usage

```shell
podman run -d \
    -p 80:80 \
    -p 443:443 \
    -e CLOUDFLARE_API_TOKEN=<token_goes_here> \
    ghcr.io/thimslugga/caddy-cloudflare:latest
```

## Caddyfile

Caddyfile examples:

```Caddyfile
*.domain.com, domain.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
}
```

## Resources

- [Caddy](https://caddyserver.com/)
- [Caddy Releases](https://github.com/caddyserver/caddy/releases)
- [Caddy Docker Image](https://hub.docker.com/r/caddy/caddy)
- [Cloudflare DNS Plugin](https://github.com/caddy-dns/cloudflare)
