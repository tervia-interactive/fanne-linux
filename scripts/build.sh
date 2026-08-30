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

# shellcheck source=../version
. ./version

export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git log -1 --format=%ct 2>/dev/null || date +%s)}"

BUILD_DATE=$(date -u -d "@${SOURCE_DATE_EPOCH}" +%Y%m%d 2>/dev/null || date -u +%Y%m%d)
BUILD_COMMIT=$(git rev-parse --short=8 HEAD 2>/dev/null || echo 'local')
FANNE_BUILD_ID="${FANNE_BUILD_ID:-${BUILD_DATE}.${BUILD_COMMIT}}"
FANNE_CODENAME_LOWER=$(printf '%s' "$FANNE_CODENAME" | tr '[:upper:]' '[:lower:]')

# Files that carry @PLACEHOLDER@ tokens filled in per build. Patched in
# place before `lb build` copies them into the chroot, then restored so
# the working tree stays clean regardless of how the build exits.
TEMPLATED_FILES='config/includes.chroot/etc/os-release config/includes.chroot/etc/issue'
cleanup() {
    for template in $TEMPLATED_FILES; do
        [ -f "${template}.orig" ] && mv "${template}.orig" "$template"
    done
}
trap cleanup EXIT INT TERM

for template in $TEMPLATED_FILES; do
    cp "$template" "${template}.orig"
    sed -i \
        -e "s/@FANNE_BUILD_ID@/${FANNE_BUILD_ID}/g" \
        -e "s/@FANNE_VERSION@/${FANNE_VERSION}/g" \
        -e "s/@FANNE_CODENAME_LOWER@/${FANNE_CODENAME_LOWER}/g" \
        -e "s/@FANNE_CODENAME@/${FANNE_CODENAME}/g" \
        "$template"
done

./scripts/clean.sh
lb config
lb build 2>&1 | tee build.log

if [ ! -f fanne-linux-amd64.hybrid.iso ]; then
    echo 'Build finished without the expected ISO file.' >&2
    exit 1
fi

RELEASE_NAME="fanne-linux-${FANNE_CODENAME_LOWER}-${FANNE_VERSION}-amd64-${FANNE_BUILD_ID}"

mkdir -p dist
cp fanne-linux-amd64.hybrid.iso "dist/${RELEASE_NAME}.iso"
ln -f "dist/${RELEASE_NAME}.iso" dist/fanne-linux-amd64.iso
(
    cd dist
    sha256sum "${RELEASE_NAME}.iso" > "${RELEASE_NAME}.iso.sha256"
    sha256sum fanne-linux-amd64.iso > fanne-linux-amd64.iso.sha256
)

echo "Build complete: dist/${RELEASE_NAME}.iso (Fanne Linux ${FANNE_CODENAME} ${FANNE_VERSION}, BUILD_ID=${FANNE_BUILD_ID})"
