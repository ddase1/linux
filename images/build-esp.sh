#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
WORK="$ROOT/.build/esp"
MODE="${ESP_MODE:-ci}"

rm -rf "$WORK"
mkdir -p "$WORK/EFI/BOOT" "$WORK/boot"

if [[ "$MODE" == "interactive" ]]; then
  CFG="$ROOT/images/grub-interactive.cfg"
else
  CFG="$ROOT/images/grub.cfg"
fi

grub-mkstandalone \
  -O x86_64-efi \
  -o "$WORK/EFI/BOOT/BOOTX64.EFI" \
  --modules="part_gpt part_msdos fat ext2 normal linux search search_label configfile" \
  "boot/grub/grub.cfg=$CFG"

cp "$OUT/bzImage" "$WORK/boot/bzImage"
cp "$OUT/initramfs.cpio.gz" "$WORK/boot/initramfs.cpio.gz"

rm -f "$OUT/esp.img"
truncate -s 128M "$OUT/esp.img"
mkfs.vfat -n DIYBOOT "$OUT/esp.img" >/dev/null

mmd -i "$OUT/esp.img" ::/EFI ::/EFI/BOOT ::/boot
mcopy -i "$OUT/esp.img" "$WORK/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI
mcopy -i "$OUT/esp.img" "$WORK/boot/bzImage" ::/boot/bzImage
mcopy -i "$OUT/esp.img" "$WORK/boot/initramfs.cpio.gz" ::/boot/initramfs.cpio.gz

echo "[esp] done ($MODE)"
