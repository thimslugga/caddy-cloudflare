# Development

Install the pinned toolchain and run the local checks:

```shell
mise install
just check
```

Use `just build` for a local image. It never pushes. See
[`RELEASING.md`](RELEASING.md) for dependency updates, version tags,
publication, and rollback.

## References

- [Caddy Server](https://caddyserver.com/)
- [Caddy Server Releases](https://github.com/caddyserver/caddy/releases)
- [Caddy Docker Image](https://hub.docker.com/r/caddy/caddy)
- [Cloudflare DNS Plugin](https://github.com/caddy-dns/cloudflare)
- [caddy-security](https://github.com/greenpau/caddy-security)
