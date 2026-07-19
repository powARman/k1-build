#!/bin/sh

. $(pwd)/build_env.sh

# Create basic debian root file system
sudo debootstrap --foreign --arch=mipsel \
    --components=contrib,main,non-free-firmware \
    --include=locales \
    bookworm "$ROOTFS_DIR"

sudo cp /usr/bin/qemu-mipsel-static "$ROOTFS_DIR"/usr/bin/

sudo chroot "$ROOTFS_DIR" /debootstrap/debootstrap --second-stage

# Set default local to prevent apt warnings
sudo chroot "$ROOTFS_DIR" sed -i 's/# en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sudo chroot "$ROOTFS_DIR" locale-gen
sudo chroot "$ROOTFS_DIR" update-locale LANG=en_US.UTF-8

# Add remaining packages
sudo chroot "$ROOTFS_DIR" apt -y install \
    bsdextrautils \
    bzip2 \
    curl \
    dialog \
    file \
    firmware-brcm80211 \
    git \
    openssh-server \
    python3-virtualenv \
    sudo \
    systemd-timesyncd \
    wireless-regdb \
    wpasupplicant \
    xz-utils

# Clean apt cache
sudo chroot "$ROOTFS_DIR" apt clean

# Add printer user
sudo chroot "$ROOTFS_DIR" adduser printer
sudo chroot "$ROOTFS_DIR" usermod -aG sudo printer

# Create swap file
sudo dd if=/dev/zero of="$ROOTFS_DIR"/swapfile bs=1M count=256
sudo chroot "$ROOTFS_DIR" chmod 0600 /swapfile
sudo chroot "$ROOTFS_DIR" mkswap /swapfile

# Copy configuration files
sudo cp -a --no-preserve=ownership k1-debian/etc/* "$ROOTFS_DIR"/etc/

# Remove host key, it will be regenerated on first boot
sudo rm "$ROOTFS_DIR"/etc/ssh/ssh_host*

# Clean up
sudo rm "$ROOTFS_DIR"/usr/bin/qemu-mipsel-static
