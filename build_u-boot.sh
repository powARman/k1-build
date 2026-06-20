#!/bin/sh

export PATH="$(pwd)/mips-ingenic-xburst2-toolchain/bin/:$PATH"

make -j$(nproc) -C k1-u-boot O=$(pwd)/out/u-boot CROSS_COMPILE=mips-linux-gnu- crealityk1_uImage_msc0
