#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

CODE="$(find_ovmf_code)"
VARS_SRC="$(find_ovmf_vars)"
VARS="$OUT/OVMF_VARS.fd"
LOG="$OUT/qemu-uefi.log"

cp "$VARS_SRC" "$VARS"
rm -f "$LOG"

set +e
timeout 120s qemu-system-x86_64 \
  -machine q35,accel=tcg \
  -m 512M \
  -smp 2 \
  -nographic \
  -no-reboot \
  -drive "if=pflash,format=raw,readonly=on,file=$CODE" \
  -drive "if=pflash,format=raw,file=$VARS" \
  -drive "file=$OUT/esp.img,format=raw,if=virtio,readonly=on" \
  -drive "file=$OUT/driver.ext4,format=raw,if=virtio,readonly=on" \
  -drive "file=$OUT/system.ext4,format=raw,if=virtio" \
  2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e

if [[ "$rc" -eq 124 ]]; then
  echo "[test-uefi] timeout" >&2
  exit 1
fi

assert_boot_log "$LOG"
echo "[test-uefi] PASS"
