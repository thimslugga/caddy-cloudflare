# Security Policy

## Supported versions

Security fixes are provided for the latest `X.Y.Z-rN` image release. Mutable
Caddy version, minor, major, and `latest` tags move to that release after
validation. Older release images remain available for rollback but do not
receive fixes.

## Report a vulnerability

Use [GitHub private vulnerability reporting][private-report] to send a report
without disclosing it publicly. Include the affected image tag or digest and
its impact. When possible, include the configuration needed to reproduce the
issue and a minimal proof of concept.

Do not open a public issue for an undisclosed vulnerability.

The maintainer aims to acknowledge a report within three business days and
provide an initial assessment within seven business days. Timing for a fix
depends on severity, reproducibility, and affected upstream components. The
reporter will receive status updates through the private advisory.

Coordinated fixes are released as a new versioned image. Security notices and
upgrade instructions are published in the corresponding GitHub Security
Advisory and GitHub Release.

[private-report]: https://github.com/thimslugga/caddy-cloudflare/security/advisories/new
