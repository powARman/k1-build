#!/bin/sh

. $(pwd)/build_env.sh

INGENIC_DIR="$BUILD_DIR/ingenic"
INGENIC_IMAGES_DIR="$INGENIC_DIR/images"
INGENIC_IMAGE_FILE="$BUILD_DIR/creality-k1-debian.ingenic"

# Remove old data
rm -rf "$INGENIC_DIR"
rm -f "$INGENIC_IMAGE_FILE"

# Create directories
mkdir -p "$INGENIC_DIR"
mkdir -p "$INGENIC_IMAGES_DIR"

# Copy data
cp -a ingenic-image/* "$INGENIC_DIR"
cp "$UBOOT_BUILD/u-boot-with-spl-mbr-gpt.bin" "$INGENIC_IMAGES_DIR"
cp "$KERNEL_BUILD/arch/mips/boot/compressed/xImage" "$INGENIC_IMAGES_DIR"
cp "$EXT4_IMAGE" "$INGENIC_IMAGES_DIR"

cd "$INGENIC_DIR"

zip -r "$INGENIC_IMAGE_FILE" ./*
