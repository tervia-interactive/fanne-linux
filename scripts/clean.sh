#!/bin/sh

set -eu

REPOSITORY_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPOSITORY_ROOT"

if command -v lb >/dev/null 2>&1; then
    lb clean --purge
fi

rm -f fanne-linux-amd64.hybrid.iso fanne-linux-amd64.hybrid.iso.zsync
rm -f fanne-linux-amd64.contents fanne-linux-amd64.packages fanne-linux-amd64.files
rm -f binary.hybrid.iso binary.hybrid.iso.zsync binary.contents binary.packages binary.files

for template in config/includes.chroot/etc/os-release config/includes.chroot/etc/issue; do
    if [ -f "${template}.orig" ]; then
        mv "${template}.orig" "$template"
    fi
done
# (This loop is intentionally guarded with an if/fi rather than `test && mv`
# so a missing .orig file — the normal case — never trips `set -e`.)

echo 'Generated live-build state removed.'
