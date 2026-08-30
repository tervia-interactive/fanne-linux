# Building Fanne Linux

## Requirements

Use a clean Debian 13 AMD64 host or virtual machine. The build downloads several
gigabytes and requires enough free disk space for the package cache, chroot, and
final image. A practical starting point is 20 GB of free space and 4 GB of RAM.

Install the host tools:

```sh
sudo apt update
sudo apt install live-build make debootstrap xorriso squashfs-tools qemu-system-x86 ovmf
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
- The installed system boots independently from the ISO.
- `apt update` and a full system upgrade complete successfully.
