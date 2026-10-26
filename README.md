# DIY Linux v0.1.1

A modular Linux proof-of-concept with three independently replaceable release units:

1. Kernel + initramfs
2. Driver volume
3. DIY System volume

Target: x86_64 + UEFI + QEMU + ext4.

## Important Windows/GitHub fix in v0.1.1

This release does **not rely on Linux executable bits** for build scripts.
All scripts are invoked explicitly with `bash`, so extracting the ZIP on Windows
and pushing it to GitHub will not break GitHub Actions.

## Build chain

```text
OVMF / direct QEMU kernel boot
        ↓
Linux kernel + initramfs
        ↓
mount Driver volume
        ↓
load diy_hello.ko
        ↓
mount System volume
        ↓
switch_root
        ↓
/sbin/init
        ↓
DIY_SYSTEM_BOOT_OK
```

## Default versions

- Linux: 6.12.114
- Kernel local version: -diy.1
- BusyBox: 1.36.1

## Ubuntu dependencies

```bash
sudo bash ./scripts/install-deps-ubuntu.sh
```

## Build

```bash
make all
```

## Test

```bash
make test
make test-uefi
```

## Interactive UEFI boot

```bash
make run
```

Press `Ctrl-A X` to exit QEMU.

## GitHub Actions

Push this repository to GitHub. The workflow:

```text
.github/workflows/build-and-boot.yml
```

will automatically:

- install dependencies
- build Linux
- build BusyBox
- build signed external module
- create initramfs
- create Driver/System ext4 images
- create EFI boot image
- test direct QEMU boot
- test OVMF/UEFI boot
- upload artifacts
