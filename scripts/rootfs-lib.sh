#!/usr/bin/env bash

install_busybox_tree() {
  local busybox="$1"
  local root="$2"

  mkdir -p "$root"/{bin,sbin,etc,proc,sys,dev,tmp,run,lib,usr/bin,usr/sbin}
  install -m 0755 "$busybox" "$root/bin/busybox"

  local bin_applets=(
    sh ash cat echo printf mkdir rmdir mount umount sleep dmesg grep sed cut
    sort uname ls ln rm mv cp readlink realpath find xargs sha256sum date
    chmod chown sync touch head tail tr test true false env
  )

  local sbin_applets=(
    mdev modprobe insmod rmmod switch_root poweroff reboot halt blkid
  )

  local a
  for a in "${bin_applets[@]}"; do
    ln -sf busybox "$root/bin/$a"
  done

  for a in "${sbin_applets[@]}"; do
    ln -sf ../bin/busybox "$root/sbin/$a"
  done
}
