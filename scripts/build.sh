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

./scripts/clean.sh
lb config
lb build 2>&1 | tee build.log

if [ ! -f fanne-linux-amd64.hybrid.iso ]; then
    echo 'Build finished without the expected ISO file.' >&2
    exit 1
fi

mkdir -p dist
cp fanne-linux-amd64.hybrid.iso dist/fanne-linux-amd64.iso
(
    cd dist
    sha256sum fanne-linux-amd64.iso > fanne-linux-amd64.iso.sha256
)

echo 'Build complete: dist/fanne-linux-amd64.iso'
