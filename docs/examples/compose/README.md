# Compose example

Copy the environment template, set `CF_API_TOKEN` and
`CADDY_SITE_ADDRESS`, then start the service:

```shell
cp .env.example .env
docker compose up --detach
```

`CADDY_IMAGE_VERSION` selects the immutable `X.Y.Z-rN` image release.
The Compose file mounts the supported Caddyfile from `../caddy/`. The
`caddy-data` and `caddy-config` volumes retain Caddy's data. Keep `.env` private
because it contains the Cloudflare API token.

Stop the service without deleting certificate data:

```shell
docker compose down
```
