# Podman Quadlet example

Install these units on a Linux host with a recent Podman release:

```shell
sudo install -d -m 0755 /etc/containers/systemd /etc/caddy
sudo install -m 0644 \
  caddy.container caddy-config.volume caddy-data.volume proxy.network \
  /etc/containers/systemd/
sudo install -m 0644 ../caddy/Caddyfile /etc/caddy/Caddyfile
sudo install -m 0600 caddy.env.example /etc/caddy/caddy.env
sudo systemctl daemon-reload
sudo systemctl start caddy.service
```

Edit `/etc/caddy/caddy.env` before starting the service. The example uses a
bridge network and publishes TCP ports 80 and 443 plus UDP port 443. The Podman
volumes retain Caddy's certificates and configuration state.

Inspect the generated service and logs with:

```shell
systemctl cat caddy.service
journalctl --unit caddy.service
```
