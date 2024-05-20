# syntax=docker/dockerfile:1
FROM ubuntu:20.04 AS build

ARG DEBIAN_FRONTEND="noninteractive"
ARG PKG_VERSION
ENV TZ="Etc/UTC"

RUN <<EOT
    set -eux
    apt-get update
    apt-get install --yes build-essential cmake curl gettext git ninja-build unzip
    apt-get clean
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
EOT

WORKDIR /source
RUN <<EOT
    set -eux
    git clone --branch v${PKG_VERSION} --depth 1 https://github.com/neovim/neovim
    cd neovim
    make CMAKE_BUILD_TYPE="Release" CMAKE_INSTALL_PREFIX="/opt/nvim" install
EOT

FROM goreleaser/nfpm:v2.37.1 AS packaging
ARG PKG_ARCHITECTURE
ARG PKG_VERSION
ARG PKG_VERSION_RELEASE

WORKDIR /opt/nvim
COPY --from=build /opt/nvim /opt/nvim
COPY <<EOF nfpm.yaml
name: neovim
description: Vim-fork focused on extensibility and usability
homepage: https://neovim.io/
license: Apache-2.0 AND Vim
maintainer: Camden DeVoogd <camdendevoogd@gmail.com>

arch: $PKG_ARCHITECTURE
version: $PKG_VERSION
release: $PKG_VERSION_RELEASE

provides:
  - nvim

contents:
  - src: bin/nvim
    dst: /usr/bin/nvim
  - src: share
    dst: /usr/share
    type: tree
  - src: lib
    dst: /usr/lib
    type: tree
EOF

RUN nfpm package --packager deb

FROM scratch AS export
COPY --from=packaging /opt/nvim/neovim*.deb .
