#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
DOCKERFILE="$SCRIPT_DIR/Dockerfile"
IMAGE_TAG="cam/neovim"
NVIM_VERSION=0.10.0
VERSION_RELEASE=1

arch="$(uname -m)"
case "$arch" in
    x86_64) arch="amd64";;
    aarch64) arch="arm64";;
esac

mkdir "$OUTPUT_DIR"
docker buildx build \
    --tag "$IMAGE_TAG" \
    --file "$DOCKERFILE" \
    --build-arg "PKG_ARCHITECTURE=$arch" \
    --build-arg "PKG_VERSION=$NVIM_VERSION" \
    --build-arg "PKG_VERSION_RELEASE=$VERSION_RELEASE" \
    --output "$OUTPUT_DIR" \
    "$SCRIPT_DIR"
