SHELL := /bin/bash
.DEFAULT_GOAL := all

export KERNEL_VERSION ?= 6.12.114
export KERNEL_LOCALVERSION ?= -diy.1
export BUSYBOX_VERSION ?= 1.36.1

.PHONY: all all-no-manifest kernel busybox drivers initramfs system images esp \
        manifest test test-uefi run clean distclean help

all: all-no-manifest manifest

all-no-manifest: kernel busybox drivers initramfs system images esp

kernel:
	bash ./kernel/build.sh

busybox:
	bash ./userspace/build-busybox.sh

drivers: kernel
	bash ./drivers/build.sh

initramfs: kernel busybox drivers
	bash ./initramfs/build.sh

system: kernel busybox drivers
	bash ./system/build.sh

images: drivers system
	bash ./images/build-data-images.sh

esp: kernel initramfs
	bash ./images/build-esp.sh

manifest: all-no-manifest
	bash ./scripts/build-release-manifest.sh

test: all
	bash ./tests/qemu/test-direct.sh

test-uefi: all
	bash ./tests/qemu/test-uefi.sh

run: all
	bash ./tests/qemu/run-interactive.sh

clean:
	rm -rf .build/staging out
	mkdir -p out

distclean:
	rm -rf .build .cache out
	mkdir -p out

help:
	@printf '%s\n' \
	  'make all        Build all artifacts' \
	  'make test       Direct QEMU boot test' \
	  'make test-uefi  OVMF + UEFI boot test' \
	  'make run        Interactive UEFI boot' \
	  'make clean      Remove staging/output' \
	  'make distclean  Also remove caches'
