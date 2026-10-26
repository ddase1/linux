#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"
KREL="$(cat "$OUT/kernelrelease")"

python3 - "$OUT" "$KREL" <<'PY'
import hashlib
import json
import pathlib
import sys

out = pathlib.Path(sys.argv[1])
krel = sys.argv[2]

names = [
    "bzImage",
    "initramfs.cpio.gz",
    "driver.ext4",
    "system.ext4",
    "esp.img",
    "kernel.config",
    "Module.symvers",
]

artifacts = []

for name in names:
    p = out / name
    if not p.exists():
        raise SystemExit(f"missing artifact: {p}")
    artifacts.append({
        "name": name,
        "bytes": p.stat().st_size,
        "sha256": hashlib.sha256(p.read_bytes()).hexdigest(),
    })

manifest = {
    "schema": 1,
    "project_release": "0.1.1",
    "architecture": "x86_64",
    "kernel_release": krel,
    "artifacts": artifacts,
}

(out / "release-manifest.json").write_text(
    json.dumps(manifest, indent=2) + "\n",
    encoding="utf-8",
)

print("[manifest] done")
PY
