# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2.8.4

# https://github.com/caddyserver/caddy-docker/issues/104#issue-665571194
FROM caddy:${CADDY_VERSION}-builder AS builder

RUN caddy-builder github.com/caddy-dns/cloudflare

#FROM caddy:${CADDY_VERSION}-alpine

ARG CADDY_VERSION=2.8.4
FROM caddy:${CADDY_VERSION}

LABEL maintainer="thimslugga"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN \
  set -eux; \
  addgroup -S -g 443 caddy; \
  adduser -S -u 443 -G caddy -D -H caddy; \
  mkdir -p /config/caddy /data/caddy; \
  chown -R caddy:caddy /config /data

USER caddy

ENV XDG_CONFIG_HOME=/config XDG_DATA_HOME=/data

VOLUME /config /data

EXPOSE 4443 8080/tcp

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
