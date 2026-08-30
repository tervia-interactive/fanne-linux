#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo 'The ISO build needs root privileges. Run: sudo make iso' >&2
    exit 1
fi

for command in lb debootstrap xorriso mksquashfs sha256sum; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Missing build dependency: $command" >&2
        exit 1
    fi
done

REPOSITORY_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPOSITORY_ROOT"

export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git log -1 --format=%ct 2>/dev/null || date +%s)}"

BUILD_DATE=$(date -u -d "@${SOURCE_DATE_EPOCH}" +%Y%m%d 2>/dev/null || date -u +%Y%m%d)
BUILD_COMMIT=$(git rev-parse --short=8 HEAD 2>/dev/null || echo 'local')
FANNE_BUILD_ID="${FANNE_BUILD_ID:-${BUILD_DATE}.${BUILD_COMMIT}}"

OS_RELEASE=config/includes.chroot/etc/os-release
cleanup() {
    if [ -f "${OS_RELEASE}.orig" ]; then
        mv "${OS_RELEASE}.orig" "$OS_RELEASE"
    fi
}
trap cleanup EXIT INT TERM

cp "$OS_RELEASE" "${OS_RELEASE}.orig"
sed -i "s/@FANNE_BUILD_ID@/${FANNE_BUILD_ID}/" "$OS_RELEASE"

./scripts/clean.sh
lb config
lb build 2>&1 | tee build.log

if [ ! -f fanne-linux-amd64.hybrid.iso ]; then
    echo 'Build finished without the expected ISO file.' >&2
    exit 1
fi

mkdir -p dist
cp fanne-linux-amd64.hybrid.iso "dist/fanne-linux-amd64-${FANNE_BUILD_ID}.iso"
ln -f "dist/fanne-linux-amd64-${FANNE_BUILD_ID}.iso" dist/fanne-linux-amd64.iso
(
    cd dist
    sha256sum "fanne-linux-amd64-${FANNE_BUILD_ID}.iso" > "fanne-linux-amd64-${FANNE_BUILD_ID}.iso.sha256"
    sha256sum fanne-linux-amd64.iso > fanne-linux-amd64.iso.sha256
)

echo "Build complete: dist/fanne-linux-amd64-${FANNE_BUILD_ID}.iso (BUILD_ID=${FANNE_BUILD_ID})"
