# Architecture

## Base system

Fanne Linux is currently a Debian derivative, not an independent package
ecosystem. Debian Unstable provides the kernel, package manager, rolling updates,
hardware enablement, and most user-space software. Fanne-owned configuration is
layered on top through `live-build` includes and hooks.

This approach lets the project spend its early effort on integration, desktop
quality, identity, and hardware testing instead of duplicating Debian's package
infrastructure.

## Image pipeline

1. `live-build` creates a minimal Debian Sid chroot.
2. Package lists add the XFCE desktop, installer, firmware, and selected apps.
3. Chroot hooks apply Fanne defaults and system identity.
4. Binary hooks and bootloader tooling create a hybrid BIOS/UEFI ISO.
5. The build script places the ISO and SHA-256 checksum in `dist/`.

## Supported target

The bootstrap target is AMD64 hardware with either legacy BIOS or UEFI.
Additional architectures should be introduced only after the AMD64 image has a
repeatable installation and update test matrix.

## Repository layout

| Path | Purpose |
| --- | --- |
| `auto/` | Persistent `live-build` command-line configuration |
| `config/package-lists/` | Packages installed into the live system |
| `config/includes.chroot/` | Files copied into the live root filesystem |
| `config/hooks/live/` | Commands executed while constructing the image |
| `scripts/` | Build, cleanup, and static validation entry points |
| `docs/` | Architecture, build, and roadmap documentation |

## Design principles

- Bootability and recoverability come before visual customization.
- Fanne-specific behavior must be reviewable in this repository.
- Defaults should be useful without preventing users from changing them.
- Upstream security updates should arrive through Debian whenever possible.
- The live session and installed system must use English by default.
- APT Recommends are off by default; a package only ships if it's listed
  explicitly or something else genuinely depends on it.
