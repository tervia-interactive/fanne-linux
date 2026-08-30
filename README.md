# Fanne Linux

Fanne Linux is a desktop-focused Linux distribution built from Debian Stable.
The project aims to provide a polished, dependable system that remains easy to
understand, rebuild, and modify.

> [!IMPORTANT]
> Fanne Linux is in its bootstrap stage. The current repository produces a
> development live image and is not ready for daily use.

## Current foundation

- Debian 13 (Trixie) base
- XFCE desktop
- Hybrid BIOS/UEFI live ISO for AMD64 computers
- Calamares graphical installer
- NetworkManager, PipeWire, Flatpak, and common desktop utilities
- English (United States) defaults
- Reproducible build configuration based on Debian `live-build`

## Build an image

Building requires a Debian 13 host or container with `live-build`, `make`,
`debootstrap`, and `xorriso` installed.

```sh
sudo apt update
sudo apt install live-build make debootstrap xorriso squashfs-tools
sudo make iso
```

The finished image and its SHA-256 checksum are written to `dist/`.

For build options and virtual-machine testing instructions, read
[`docs/building.md`](docs/building.md).

## Project status

The first milestone is intentionally small: produce a clean, bootable,
installable image before adding extensive visual customization or Fanne-owned
system components. See [`docs/roadmap.md`](docs/roadmap.md) for the planned
stages.

## Contributing

Contributions are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before
opening a pull request.

## License

Repository-owned source code and configuration are licensed under the
[Apache License 2.0](LICENSE). Included Debian packages keep their respective
upstream licenses.
