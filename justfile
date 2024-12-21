#!/usr/bin/env just --justfile

################################################################################
## justfile
################################################################################

set unstable := false
set allow-duplicate-recipes := false
set allow-duplicate-variables := false
#set positional-arguments := true
set dotenv-required := false
set dotenv-load := true
#set dotenv-path := env_var('PWD')
set dotenv-filename := ".env"
set export := false

################################################################################
## Recipes
################################################################################

# Lists the tasks and variables in the justfile.
@_list:
    just --justfile {{justfile()}} --list --unsorted
    echo ""
    echo "Available variables:"
    just --evaluate | sed 's/^/    /'
    echo ""
    echo "Override variables using 'just key=value ...' (also ALL_UPPERCASE ones)"

[doc('Evaluate and return all just variables')]
evaluate:
    @just --evaluate

[doc('List available recipes')]
help:
    @just --justfile {{justfile()}} --list

[doc('Just format')]
format:
    just --justfile {{justfile()}} --fmt

[doc('Return system information')]
system-info:
    @echo "os: {{os()}}"
    @echo "family: {{os_family()}}"
    @echo "architecture: {{arch()}}"
    @echo "home directory: {{ home_directory() }}"

################################################################################
## Git
################################################################################

[doc('Add all changes to the git index')]
ga:
    git add .

[doc('Commit all changes')]
gc:
    git commit -m "commit message"

[doc('Push all changes to the remote')]
gp:
    git push

################################################################################
## Docker
################################################################################

[doc('Build and push cadd-cloudflare image to the remote docker registry')]
build-push:
    docker buildx build --platform linux/amd64,linux/arm64 \
        --push \
        --progress plain \
        -t ghcr.io/thimslugga/caddy-cloudflare:latest \
        -t ghcr.io/thimslugga:caddy-cloudflare:${VERSION} \
        -f ./Dockerfile \
        "$@" \
        .

[doc('Build and push caddy-cloudflare alpine image to the remote docker registry')]
build-push-alpine:
    docker buildx build --platform linux/amd64,linux/arm64 \
        --push \
        --progress plain \
        -t ghcr.io/thimslugga/caddy-cloudflare:latest-alpine \
        -t ghcr.io/thimslugga:caddy-cloudflare:${VERSION}-alpine \
        -f ./Dockerfile \
        "$@" \
        .
