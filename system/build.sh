#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
STAGE="$ROOT/.build/staging/system"

source "$ROOT/scripts/rootfs-lib.sh"

rm -rf "$STAGE"
mkdir -p "$STAGE"

install_busybox_tree "$OUT/busybox" "$STAGE"
cp -a "$ROOT/system/rootfs/." "$STAGE/"

chmod +x "$STAGE/sbin/init" "$STAGE/usr/sbin/driverctl"

mkdir -p "$STAGE"/{root,home,var/log,var/lib,run/driver-disk,lib/modules}
echo "root:x:0:0:root:/root:/bin/sh" > "$STAGE/etc/passwd"
echo "root:x:0:" > "$STAGE/etc/group"

echo "[system] done"
