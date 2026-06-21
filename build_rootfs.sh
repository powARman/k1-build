#!/bin/sh

. $(pwd)/build_env.sh

# Remove old data
rm -f "$EXT4_IMAGE"
sudo rm -rf "$ROOTFS_DIR"

# Create ext4 image
truncate -s 1536M "$EXT4_IMAGE"
mkfs -t ext4 "$EXT4_IMAGE"

# Mount ext4 image
mkdir -p "$ROOTFS_DIR"
sudo mount -o loop "$EXT4_IMAGE" "$ROOTFS_DIR"

# Build debian root file system
./build_debian.sh

# Add kernel modules to root file system
./build_linux_install.sh

# Unmount ext4 image
sudo umount "$ROOTFS_DIR"
