
export BUILD_DIR="$(pwd)/out"

export MCU_FW_BUILD="$BUILD_DIR/mcu_fw"

export UBOOT_SRC="$(pwd)/k1-u-boot"
export UBOOT_BUILD="$BUILD_DIR/u-boot"

export KERNEL_SRC="$(pwd)/k1-linux"
export KERNEL_BUILD="$BUILD_DIR/linux"

export ROOTFS_DIR="$BUILD_DIR/debian-rootfs"
export EXT4_IMAGE="$BUILD_DIR/ext4.img"

export PATH="$(pwd)/mips-ingenic-xburst2-toolchain/bin/:$PATH"
