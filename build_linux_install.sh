#!/bin/sh

. $(pwd)/build_env.sh

sudo make -C "$KERNEL_SRC" O="$KERNEL_BUILD" INSTALL_MOD_PATH="$ROOTFS_DIR" modules_install
