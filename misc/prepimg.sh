#!/bin/sh
# This file is part of roundshot
# See LICENSE file for copyright and license details.

IMGNAME="decode-1.0.0"
FSTYPE="ext4"
SIZE="1024"

echo "Creating zeroed image..."

dd if=/dev/zero of="${IMGNAME}.img" bs=1M count=$SIZE

echo "Partitioning..."
parted "${IMGNAME}.img" --script -- mklabel msdos
parted "${IMGNAME}.img" --script -- mkpart primary $FSTYPE 8192s 100%

loopdev="$(partx -av "${IMGNAME}.img" | tail -n1 | cut -d: -f1)"
mkfs.$FSTYPE "${loopdev}p1"

echo "Mounting as loop device..."
mkdir -p mnt
mount "${loopdev}p1" ./mnt

echo "Copyring fies..."
cp -v filesystem.squashfs mnt
cp -v linux-build/sun7i-a20-olinuxino-lime2.dtb mnt
cp -v linux-build/zImage mnt
cp -v ../misc/boot.txt mnt
mkimage -A arm -T ramdisk -C none -n uInitrd -d initramfs.cpio.bz2 mnt/initramfs.cpio.bz2.img
mkimage -A arm -T script -C none -d mnt/boot.txt mnt/boot.scr

echo "Unmounting loop device..."
umount ./mnt
partx -dv "$loopdev"
losetup -d "$loopdev"
rmdir mnt

#echo "Writing bootloader...
#dd if=u-boot-sunxi-with-spl.bin of="${IMGNAME}.img" bs=1024 seek=8
