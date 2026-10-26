#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
STAGE="$ROOT/.build/staging/initramfs"

source "$ROOT/scripts/rootfs-lib.sh"

rm -rf "$STAGE"
mkdir -p "$STAGE"

install_busybox_tree "$OUT/busybox" "$STAGE"
install -m 0755 "$ROOT/initramfs/init" "$STAGE/init"

(
  cd "$STAGE"
  find . -print0 \
    | cpio --null -ov --format=newc 2>/dev/null \
    | gzip -9 > "$OUT/initramfs.cpio.gz"
)

echo "[initramfs] done"
