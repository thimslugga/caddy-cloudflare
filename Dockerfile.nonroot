# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2.8.4
FROM caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
        --with github.com/caddy-dns/cloudflare \
        --with github.com/greenpau/caddy-security

FROM caddy:${CADDY_VERSION}

LABEL maintainer="thimslugga"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
