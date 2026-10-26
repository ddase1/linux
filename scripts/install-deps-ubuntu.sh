#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential bc bison flex libssl-dev libelf-dev dwarves \
  cpio rsync curl xz-utils bzip2 gzip git kmod \
  e2fsprogs dosfstools mtools \
  qemu-system-x86 ovmf \
  grub-efi-amd64-bin grub-common \
  python3
