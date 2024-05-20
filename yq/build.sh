#!/usr/bin/env bash
set -euo pipefail

ARCHITECTURES=(amd64 arm64)
export PKG_VERSION=4.44.1
export PKG_VERSION_RELEASE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NFPM_CONFIG="$SCRIPT_DIR/nfpm.yaml"
OUTPUT_DIR="$SCRIPT_DIR/output"
DOWNLOAD_DIR="$OUTPUT_DIR/downloads"
EXTRACTION_DIR="$OUTPUT_DIR/extracted"
PACKAGE_DIR="$OUTPUT_DIR/packages"

log() {
   echo "[*]" "$@"
}

clean_output() {
    log "Recreating the full output directory"
    rm -rf "$OUTPUT_DIR"
    mkdir "$OUTPUT_DIR" "$DOWNLOAD_DIR" "$EXTRACTION_DIR" "$PACKAGE_DIR"
}

download_release_tarball() {
    local arch="$1"
    local outfile="$2"

    local url="https://github.com/mikefarah/yq/releases/download/v${PKG_VERSION}/yq_linux_${arch}.tar.gz"
    log "Downloading yq for $arch: $url"
    curl --fail --silent --show-error --location --output "$outfile" "$url"
}

extract_release() {
    local tarball="$1"

    log "Recreating the extraction directory: $EXTRACTION_DIR"
    rm -rf "$EXTRACTION_DIR"
    mkdir "$EXTRACTION_DIR"

    log "Extracting yq release: $tarball"
    tar xvf "$tarball" --directory "$EXTRACTION_DIR"
}

package_release() {
    local architecture="$1"

    log "Packaging yq for $arch"
    export PKG_ARCHITECTURE="$architecture"
    nfpm package --packager deb --config "$NFPM_CONFIG" --target "$PACKAGE_DIR"
}

main() {
    pushd "$SCRIPT_DIR"
    clean_output
    for arch in "${ARCHITECTURES[@]}"; do
        local tarball="$DOWNLOAD_DIR/yq-$arch.tar.gz"
        download_release_tarball "$arch" "$tarball"
        extract_release "$tarball"
        package_release "$arch"
    done
}

main "$@"
