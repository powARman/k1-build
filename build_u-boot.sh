#!/bin/sh

. $(pwd)/build_env.sh

make -j$(nproc) -C "$UBOOT_SRC" O="$BUILD_DIR/u-boot" CROSS_COMPILE=mips-linux-gnu- crealityk1_uImage_msc0
