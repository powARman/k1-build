
export BUILD_DIR="$(pwd)/out"

export UBOOT_SRC="$(pwd)/k1-u-boot"
export UBOOT_BUILD="$BUILD_DIR/u-boot"

export KERNEL_SRC="$(pwd)/k1-linux"
export KERNEL_BUILD="$BUILD_DIR/linux"
export ROOTFS_DIR="$BUILD_DIR/debian-rootfs"

export PATH="$(pwd)/mips-ingenic-xburst2-toolchain/bin/:$PATH"
