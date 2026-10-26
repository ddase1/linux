# Architecture

## Three release units

### Kernel release

Contains the Linux kernel and the minimal early-userspace environment.

Boot-critical support remains built into the kernel so the Driver volume can
always be reached.

### Driver release

Contains:

```text
/lib/modules/<kernel-release>/
/lib/firmware/
/driver-manifest.json
/SHA256SUMS
```

The module ABI boundary is the exact kernel release reported by `uname -r`.

### System release

Contains:

```text
/sbin/init
/usr/sbin/driverctl
/bin/busybox
/etc/*
```

The System volume is intentionally independent from the module payload.

## Boot-critical closure

The kernel cannot depend on a Driver volume for the only driver needed to reach
that Driver volume.

Therefore V0.1 builds in the QEMU VirtIO block path plus real-machine baseline
storage support such as NVMe, AHCI, USB storage, and ext4.

## Module security

V0.1 enables kernel module signatures and signs the sample external module
with the kernel build signing key.

Production should replace the ephemeral build key with an offline-managed
release key and add Secure Boot key management.
