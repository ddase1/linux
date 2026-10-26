#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/.build"
CACHE="$ROOT/.cache"
OUT="$ROOT/out"

KERNEL_VERSION="${KERNEL_VERSION:-6.12.114}"
KERNEL_LOCALVERSION="${KERNEL_LOCALVERSION:--diy.1}"
MAJOR="${KERNEL_VERSION%%.*}"
TARBALL="linux-${KERNEL_VERSION}.tar.xz"
URL="https://cdn.kernel.org/pub/linux/kernel/v${MAJOR}.x/${TARBALL}"
SRC="$BUILD/linux-${KERNEL_VERSION}"

mkdir -p "$BUILD" "$CACHE" "$OUT"

if [[ ! -f "$CACHE/$TARBALL" ]]; then
  echo "[kernel] downloading $URL"
  curl -fL --retry 3 -o "$CACHE/$TARBALL" "$URL"
fi

if [[ ! -d "$SRC" ]]; then
  echo "[kernel] extracting $TARBALL"
  tar -C "$BUILD" -xf "$CACHE/$TARBALL"
fi

cd "$SRC"

make x86_64_defconfig

scripts/config --enable MODULES
scripts/config --enable BLK_DEV_INITRD
scripts/config --enable DEVTMPFS
scripts/config --enable DEVTMPFS_MOUNT
scripts/config --enable TMPFS
scripts/config --enable TMPFS_POSIX_ACL
scripts/config --set-str LOCALVERSION "$KERNEL_LOCALVERSION"
scripts/config --disable LOCALVERSION_AUTO

scripts/config --enable EFI
scripts/config --enable EFI_STUB
scripts/config --enable SERIAL_8250
scripts/config --enable SERIAL_8250_CONSOLE

scripts/config --enable PCI
scripts/config --enable VIRTIO
scripts/config --enable VIRTIO_PCI
scripts/config --enable VIRTIO_BLK
scripts/config --enable EXT4_FS

scripts/config --enable BLK_DEV_NVME
scripts/config --enable ATA
scripts/config --enable SATA_AHCI
scripts/config --enable USB
scripts/config --enable USB_XHCI_HCD
scripts/config --enable USB_EHCI_HCD
scripts/config --enable USB_OHCI_HCD
scripts/config --enable USB_STORAGE

scripts/config --enable NET
scripts/config --enable INET
scripts/config --module VIRTIO_NET

scripts/config --enable FW_LOADER
scripts/config --enable KALLSYMS
scripts/config --enable MODULE_UNLOAD
scripts/config --enable MODVERSIONS
scripts/config --enable MODULE_SIG
scripts/config --enable MODULE_SIG_ALL
scripts/config --enable MODULE_SIG_FORCE
scripts/config --enable MODULE_SIG_SHA256

scripts/config --enable PROC_FS
scripts/config --enable SYSFS

make olddefconfig

JOBS="${JOBS:-$(nproc)}"
echo "[kernel] compiling with ${JOBS} jobs"
make -j"$JOBS" bzImage modules

KREL="$(make -s kernelrelease)"
printf '%s\n' "$KREL" > "$OUT/kernelrelease"
cp arch/x86/boot/bzImage "$OUT/bzImage"
cp .config "$OUT/kernel.config"
cp Module.symvers "$OUT/Module.symvers"

rm -rf "$OUT/kernel-modules"
make modules_install INSTALL_MOD_PATH="$OUT/kernel-modules"

if [[ -f certs/signing_key.x509 ]]; then
  cp certs/signing_key.x509 "$OUT/module-signing-key.x509"
fi

echo "[kernel] done: $KREL"
