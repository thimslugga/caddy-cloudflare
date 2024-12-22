# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2.8.4
FROM caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
        --with github.com/caddy-dns/cloudflare \
        --with github.com/greenpau/caddy-security

FROM caddy:${CADDY_VERSION}

LABEL org.opencontainers.image.title="caddy-cloudflare" \
  org.opencontainers.image.description="Caddy container image with Cloudflare DNS plugin included." \
  org.opencontainers.image.authors="thimslugga" \
  org.opencontainers.image.url="https://github.com/thimslugga/caddy-cloudflare" \
  org.opencontainers.image.source="https://github.com/thimslugga/caddy-cloudflare" \
  org.opencontainers.image.documentation="https://github.com/thimslugga/caddy-cloudflare/blob/main/README.md" \
  org.opencontainers.image.version="${CADDY_VERSION}" \
  org.opencontainers.image.created="${BUILD_DATE}"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
