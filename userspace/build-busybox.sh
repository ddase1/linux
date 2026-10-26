#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/.build"
CACHE="$ROOT/.cache"
OUT="$ROOT/out"

BUSYBOX_VERSION="${BUSYBOX_VERSION:-1.36.1}"
TARBALL="busybox-${BUSYBOX_VERSION}.tar.bz2"
URL="https://busybox.net/downloads/${TARBALL}"
SRC="$BUILD/busybox-${BUSYBOX_VERSION}"

mkdir -p "$BUILD" "$CACHE" "$OUT"

if [[ ! -f "$CACHE/$TARBALL" ]]; then
  echo "[busybox] downloading $URL"
  curl -fL --retry 3 -o "$CACHE/$TARBALL" "$URL"
fi

if [[ ! -d "$SRC" ]]; then
  tar -C "$BUILD" -xf "$CACHE/$TARBALL"
fi

cd "$SRC"
make defconfig

if grep -q '^# CONFIG_STATIC is not set' .config; then
  sed -i 's/^# CONFIG_STATIC is not set$/CONFIG_STATIC=y/' .config
else
  scripts/config --enable STATIC 2>/dev/null || true
fi

yes "" | make oldconfig >/dev/null

JOBS="${JOBS:-$(nproc)}"
make -j"$JOBS"

cp busybox "$OUT/busybox"
chmod +x "$OUT/busybox"

echo "[busybox] done"
