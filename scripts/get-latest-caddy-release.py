#!/usr/bin/env python3

"""Print the latest stable Caddy server release version."""

import json
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

RELEASE_URL = "https://api.github.com/repos/caddyserver/caddy/releases/latest"
REQUEST_TIMEOUT_SECONDS = 10


class InvalidReleaseResponseError(ValueError):
    """Report a GitHub release response without a usable tag."""

    def __init__(self) -> None:
        """Initialize the error with a diagnostic message."""
        super().__init__("GitHub response does not contain a valid 'tag_name'")


def get_latest_release() -> str:
    """Retrieve the latest stable Caddy version from GitHub."""
    request = Request(
        RELEASE_URL,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "caddy-cloudflare-release-checker",
        },
    )

    # RELEASE_URL is a fixed HTTPS endpoint rather than caller-controlled input.
    with urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS) as response:  # noqa: S310
        release = json.load(response)

    tag_name = release.get("tag_name")
    if not isinstance(tag_name, str) or not tag_name:
        raise InvalidReleaseResponseError

    return tag_name.removeprefix("v")


def main() -> int:
    """Print the latest version, returning a nonzero status on failure."""
    try:
        latest_release = get_latest_release()
    except (HTTPError, URLError, TimeoutError, json.JSONDecodeError, ValueError) as error:
        sys.stderr.write(f"Unable to retrieve the latest Caddy version: {error}\n")
        return 1

    sys.stdout.write(f"{latest_release}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
