#!/bin/sh

KSRC="$(pwd)/k1-linux"
KBUILD="$(pwd)/out/linux"

export PATH="$(pwd)/mips-ingenic-xburst2-toolchain/bin/:$PATH"

make -C "$KSRC" O="$KBUILD" x2000_k1_linux_defconfig

make -j$(nproc) -C "$KSRC" O="$KBUILD" xImage
