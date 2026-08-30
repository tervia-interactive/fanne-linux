#!/bin/sh

set -eu

REPOSITORY_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPOSITORY_ROOT"

required_files='auto/config
version
config/package-lists/fanne.list.chroot
config/hooks/live/010-fanne-system.hook.chroot
config/hooks/live/020-fanne-boot-branding.hook.binary
config/includes.chroot/etc/os-release
config/includes.chroot/etc/issue
config/includes.chroot/etc/calamares/branding/fanne/branding.desc
config/includes.chroot/usr/share/backgrounds/fanne/fanne-default.png
config/bootloaders/fanne-splash.png
docs/architecture.md
docs/building.md'

for path in $required_files; do
    if [ ! -f "$path" ]; then
        echo "Missing required file: $path" >&2
        exit 1
    fi
done

for script in auto/config version config/hooks/live/010-fanne-system.hook.chroot scripts/build.sh scripts/clean.sh scripts/check.sh; do
    sh -n "$script"
done

sh -n config/hooks/live/020-fanne-boot-branding.hook.binary
sh -n config/includes.chroot/usr/local/bin/fanne-installer

if ! (. ./version && [ -n "${FANNE_VERSION:-}" ] && [ -n "${FANNE_CODENAME:-}" ]); then
    echo 'version must define both FANNE_VERSION and FANNE_CODENAME.' >&2
    exit 1
fi

if ! grep -q -- '--distribution sid' auto/config; then
    echo 'The image is not configured to use Debian Sid.' >&2
    exit 1
fi

if grep -RInE 'branding:[[:space:]]*debian|Name=Install Debian' config --exclude='010-fanne-system.hook.chroot'; then
    echo 'Visible Debian installer branding found.' >&2
    exit 1
fi

if grep -RInE '(^|[^[:alpha:]])(pt_BR|Portuguese|Português)([^[:alpha:]]|$)' \
    README.md CONTRIBUTING.md docs auto config; then
    echo 'Non-English locale or language marker found.' >&2
    exit 1
fi

echo 'Fanne Linux configuration checks passed.'
