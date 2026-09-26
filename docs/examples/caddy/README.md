# Caddyfile example

The supported example uses the Cloudflare DNS module included in the image.
Set `CADDY_SITE_ADDRESS` to a hostname in a Cloudflare managed zone and set
`CF_API_TOKEN` to a scoped Cloudflare API token.

Validate it with the project image:

```shell
docker run --rm \
  --env CF_API_TOKEN \
  --env CADDY_SITE_ADDRESS \
  --volume "${PWD}/Caddyfile:/etc/caddy/Caddyfile:ro" \
  ghcr.io/thimslugga/caddy-cloudflare:2.11.4-r1 \
  validate --config /etc/caddy/Caddyfile --adapter caddyfile
```

The Cloudflare Origin CA issuer example was removed because it needs a module
that is absent from this image and has a certificate renewal limitation.
