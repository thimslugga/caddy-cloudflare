# Contributing

Before starting a change, search existing [issues][issues] and
[pull requests][pull-requests]. Open an issue when a change needs design or
scope discussion.

## Development checks

Install the pinned project tools and run the complete local check:

```shell
mise install
just check
```

Container changes should also pass `just build` on a host with Docker and
Buildx. Pull requests build the primary image, verify its Caddy version and
modules, validate supported examples, run a smoke test, and scan the image.

Keep `CADDY_VERSION`, dependency pins, and documentation synchronized. Do not
add secrets, Cloudflare tokens, or private hostnames to examples or test data.

[issues]: https://github.com/thimslugga/caddy-cloudflare/issues
[pull-requests]: https://github.com/thimslugga/caddy-cloudflare/pulls
