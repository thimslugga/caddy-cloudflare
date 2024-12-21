# caddy-cloudflare

Caddy container image(s) with Cloudflare DNS plugin included.

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
