# Building Fanne Linux

## Requirements

Use a clean Devuan Ceres (unstable) AMD64 host or the repository's Devuan Ceres
container workflow — see `.github/workflows/build.yml`, which builds inside
`devuan/devuan:ceres`. Building on plain Debian is possible but not
recommended: `debootstrap` needs `devuan-keyring` to verify the Devuan
archive, and that package isn't in Debian's own repositories, so you'd have
to fetch and trust it out of band. On a Devuan host it's just an `apt install`
away. The build downloads several gigabytes and requires enough free disk
space for the package cache, chroot, and final image. A practical starting
point is 20 GB of free space and 4 GB of RAM.

Install the host tools:

```sh
sudo apt update
sudo apt install live-build make debootstrap xorriso squashfs-tools qemu-system-x86 ovmf devuan-keyring
```

## Build

From the repository root:

```sh
sudo make iso
```

To remove all generated live-build state:

```sh
sudo make clean
```

The build script starts from a clean live-build state. Successful output is
placed at:

```text
dist/fanne-linux-amd64.iso
dist/fanne-linux-amd64.iso.sha256
```

## Test with QEMU

Legacy BIOS boot:

```sh
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 \
  -cdrom dist/fanne-linux-amd64.iso
```

UEFI boot:

```sh
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 \
  -bios /usr/share/OVMF/OVMF_CODE.fd \
  -cdrom dist/fanne-linux-amd64.iso
```

## Minimum release checks

- The ISO boots in both BIOS and UEFI modes.
- The live session reaches XFCE without manual intervention.
- Wired and Wi-Fi networking can be configured through NetworkManager.
- Audio playback works through PipeWire.
- Calamares completes an installation in a disposable virtual disk.
- Calamares' "Extra software" step installs correctly with each item
  individually selected, and correctly skips them all when none are
  selected. This step requires internet access during install (the
  packages are not on the live squashfs); test both with and without a
  network connection to confirm the offline case degrades gracefully
  rather than hanging.
- The installed system boots independently from the ISO.
- `apt update` and a full system upgrade complete successfully.
