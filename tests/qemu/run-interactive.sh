#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

CODE="$(find_ovmf_code)"
VARS_SRC="$(find_ovmf_vars)"
VARS="$OUT/OVMF_VARS.interactive.fd"

ESP_MODE=interactive bash "$ROOT/images/build-esp.sh"
cp "$VARS_SRC" "$VARS"

qemu-system-x86_64 \
  -machine q35,accel=tcg \
  -m 1G \
  -smp 2 \
  -nographic \
  -drive "if=pflash,format=raw,readonly=on,file=$CODE" \
  -drive "if=pflash,format=raw,file=$VARS" \
  -drive "file=$OUT/esp.img,format=raw,if=virtio,readonly=on" \
  -drive "file=$OUT/driver.ext4,format=raw,if=virtio,readonly=on" \
  -drive "file=$OUT/system.ext4,format=raw,if=virtio" \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0
