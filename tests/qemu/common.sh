#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/out"

find_ovmf_code() {
  for f in \
    /usr/share/OVMF/OVMF_CODE_4M.fd \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/edk2/ovmf/OVMF_CODE.fd
  do
    [[ -r "$f" ]] && { echo "$f"; return 0; }
  done
  echo "OVMF code firmware not found" >&2
  return 1
}

find_ovmf_vars() {
  for f in \
    /usr/share/OVMF/OVMF_VARS_4M.fd \
    /usr/share/OVMF/OVMF_VARS.fd \
    /usr/share/edk2/ovmf/OVMF_VARS.fd
  do
    [[ -r "$f" ]] && { echo "$f"; return 0; }
  done
  echo "OVMF vars firmware not found" >&2
  return 1
}

assert_boot_log() {
  local log="$1"
  grep -q "DIY_DRIVER_DISK_OK" "$log"
  grep -q "DIY_DRIVER_LOADED: diy_hello" "$log"
  grep -q "DIY_SYSTEM_BOOT_OK" "$log"
}
