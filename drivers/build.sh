#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
STAGE="$ROOT/.build/staging/driver"
KERNEL_VERSION="${KERNEL_VERSION:-6.12.114}"
KSRC="$ROOT/.build/linux-${KERNEL_VERSION}"
KREL="$(cat "$OUT/kernelrelease")"
MODSRC="$ROOT/drivers/external/diy_hello"

rm -rf "$STAGE"
mkdir -p "$STAGE/lib/modules" "$STAGE/lib/firmware"

cp -a "$OUT/kernel-modules/lib/modules/$KREL" "$STAGE/lib/modules/"

make -C "$KSRC" M="$MODSRC" clean
make -C "$KSRC" M="$MODSRC" modules

"$KSRC/scripts/sign-file" sha256 \
  "$KSRC/certs/signing_key.pem" \
  "$KSRC/certs/signing_key.x509" \
  "$MODSRC/diy_hello.ko"

mkdir -p "$STAGE/lib/modules/$KREL/extra"
install -m 0644 "$MODSRC/diy_hello.ko" \
  "$STAGE/lib/modules/$KREL/extra/diy_hello.ko"

depmod -b "$STAGE" "$KREL"

cat > "$STAGE/driver-manifest.json" <<EOF
{
  "schema": 1,
  "release": "0.1.1",
  "architecture": "x86_64",
  "kernel_release": "$KREL",
  "packages": [
    {
      "name": "diy-hello",
      "version": "0.1.1",
      "modules": ["diy_hello"],
      "boot_critical": false
    }
  ]
}
EOF

(
  cd "$STAGE"
  find lib -type f -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
)

echo "[drivers] done"
