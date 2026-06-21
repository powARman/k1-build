#!/bin/sh

. $(pwd)/build_env.sh

make -C "$KERNEL_SRC" O="$KERNEL_BUILD" x2000_k1_linux_defconfig

make -j$(nproc) -C "$KERNEL_SRC" O="$KERNEL_BUILD" xImage
