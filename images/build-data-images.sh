#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
DRIVER_STAGE="$ROOT/.build/staging/driver"
SYSTEM_STAGE="$ROOT/.build/staging/system"

mkdir -p "$OUT"

rm -f "$OUT/driver.ext4" "$OUT/system.ext4"

truncate -s 256M "$OUT/driver.ext4"
mke2fs -q -F -t ext4 -L DRIVER -d "$DRIVER_STAGE" "$OUT/driver.ext4"

truncate -s 256M "$OUT/system.ext4"
mke2fs -q -F -t ext4 -L DIYSYSTEM -d "$SYSTEM_STAGE" "$OUT/system.ext4"

echo "[images] driver.ext4 + system.ext4 done"
