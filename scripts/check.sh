#!/bin/sh

set -eu

REPOSITORY_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPOSITORY_ROOT"

required_files='auto/config
config/package-lists/fanne.list.chroot
config/hooks/live/010-fanne-system.hook.chroot
config/includes.chroot/etc/os-release
docs/architecture.md
docs/building.md'

for path in $required_files; do
    if [ ! -f "$path" ]; then
        echo "Missing required file: $path" >&2
        exit 1
    fi
done

for script in auto/config config/hooks/live/010-fanne-system.hook.chroot scripts/build.sh scripts/clean.sh scripts/check.sh; do
    sh -n "$script"
done

if grep -RInE '(^|[^[:alpha:]])(pt_BR|Portuguese|Português)([^[:alpha:]]|$)' \
    README.md CONTRIBUTING.md docs auto config; then
    echo 'Non-English locale or language marker found.' >&2
    exit 1
fi

echo 'Fanne Linux configuration checks passed.'
