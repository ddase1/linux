#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

LOG="$OUT/qemu-direct.log"
rm -f "$LOG"

set +e
timeout 90s qemu-system-x86_64 \
  -machine q35,accel=tcg \
  -m 512M \
  -smp 2 \
  -nographic \
  -no-reboot \
  -kernel "$OUT/bzImage" \
  -initrd "$OUT/initramfs.cpio.gz" \
  -append "console=ttyS0,115200 driverdev=/dev/vda systemdev=/dev/vdb diy.ci=1" \
  -drive "file=$OUT/driver.ext4,format=raw,if=virtio,readonly=on" \
  -drive "file=$OUT/system.ext4,format=raw,if=virtio" \
  2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e

if [[ "$rc" -eq 124 ]]; then
  echo "[test-direct] timeout" >&2
  exit 1
fi

assert_boot_log "$LOG"
echo "[test-direct] PASS"
