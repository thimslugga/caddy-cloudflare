# Dockerfile examples

The root project `Dockerfile` defines the published image. These Dockerfiles
show Alpine based and non-root variants and are built by CI as examples. They
are not published as separate supported tags.

Build an example from the repository root:

```shell
docker build \
  --build-arg CADDY_VERSION="$(<CADDY_VERSION)" \
  --build-arg IMAGE_VERSION=example-rootless \
  --file docs/examples/dockerfile/Dockerfile.rootless \
  --tag caddy-cloudflare:rootless \
  .
```
