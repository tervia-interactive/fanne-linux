#!/bin/sh

set -eu

REPOSITORY_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPOSITORY_ROOT"

# Don't gate this on `lb clean --purge` or a .buildconfig marker: this repo's
# live-build version tracks state in .build/, not .buildconfig, so that
# marker is never present and `lb clean` never actually ran. Remove every
# live-build generated directory directly instead, so a previous run (even
# one that was interrupted, e.g. mid-debootstrap) never leaves stale files
# behind that make the next `tar` extraction fail with "File exists".
rm -rf .build .stage binary cache chroot local
rm -f .buildconfig auto/build auto/clean auto/config.old

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
