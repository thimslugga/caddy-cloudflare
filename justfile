#!/usr/bin/env just --justfile

set dotenv-load
set shell := ["bash", "-euo", "pipefail", "-c"]
set unstable

caddy_version := trim(read("CADDY_VERSION"))
registry := env("REGISTRY", "ghcr.io")
image_name := env("IMAGE_NAME", "thimslugga/caddy-cloudflare")
image := registry + "/" + image_name
dev_tag := image + ":dev"

[default]
[doc("List available recipes")]
help:
    @just --list

[doc("Run all local static checks")]
check:
    actionlint -color=false .github/workflows/*.yml
    yamllint -f parsable .
    rumdl check . --color never --exclude "docs/styles/**"
    hadolint Dockerfile docs/examples/dockerfile/Dockerfile*
    just --fmt --check
    uv sync --frozen
    uv run --frozen --no-sync ruff check .
    uv run --frozen --no-sync ruff format --check .
    uv run --frozen --no-sync ty check scripts/get-latest-caddy-release.py
    uv run --frozen --no-sync mypy scripts/get-latest-caddy-release.py
    uv run --frozen --no-sync pytest
    vale sync
    vale README.md CHANGELOG.md .github/CONTRIBUTING.md .github/SECURITY.md docs/DEVELOPMENT.md docs/RELEASING.md docs/examples
    git diff --check

[doc("Print the configured Caddy version")]
show-version:
    @printf '%s\n' "{{ caddy_version }}"

[doc("Print the latest stable Caddy version")]
latest-version:
    @scripts/get-latest-caddy-release.py

[private]
[script("bash")]
validate-version candidate=caddy_version:
    set -Eeuo pipefail

    readonly candidate="{{ candidate }}"
    if [[ ! "${candidate}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      printf 'Invalid Caddy version: %s\n' "${candidate}" >&2
      exit 1
    fi

[doc("Build the primary image without publishing it")]
[script("bash")]
build tag=dev_tag: (validate-version caddy_version)
    set -Eeuo pipefail

    readonly build_date="$(git show -s --format=%cI HEAD)"
    readonly revision="$(git rev-parse HEAD)"
    docker build \
      --build-arg "BUILD_DATE=${build_date}" \
      --build-arg "CADDY_VERSION={{ caddy_version }}" \
      --build-arg "IMAGE_VERSION=dev" \
      --build-arg "VCS_REF=${revision}" \
      --tag "{{ tag }}" \
      .
