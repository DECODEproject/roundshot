# Roundshot - upgradable OS image build system

This software takes the tar.gz of a GNU/Linux operating system
(i.e. the rootfs image produced by the
[https://github.com/DECODEproject/os-build-system](os-build-system)
using Devuan's SDK) and builds a ramdisk using busybox, musl-libc, a
squashfs image and a uboot patched Linux kernel.

It results in a directory ready to be copied to an SDcard with init
scripts that manage booting, mounting the overlayfs over the squashfs
image (for variable data) and eventually checking updates on a
configured website, verifying their hash and signature and replacing
the squashfs with the new version.

Roundshot is aimed at readability and verifiability of this
process: it is mostly made of shell scripts and GNU makefile standard
targets, while keeping all the source-code short and readable.

Right now roundshot is deployed specifically for the DECODE project
and is tailored to target Olimex Lime2 boards with a Linux kernel
patched with grsec.

## List of components

Being in charge of compositing a boot system that checks online for
signed upgrades, the main components managed by roundshot are the
kernel, the filesystem and the ramdisk.

### Linux kernel

The kernel used is Linux 4.9 hardened with grsec patches.

### Filesystem

The filesystems used are overlayfs, squashfs and btrfs.

### Initramfs

The first 'volatile' stage of the booting is made in a minimal ramdisk
containing only: busybox, udhcpc, gpgv and a keyring.

## Startup sequence

For an outline of the operations executed by the ramdisk, reading the
[/blob/master/initramfs/skel/init](init file) is self-explanatory to
anyone with a bit of shell-scripting. Here an excerpt of the main
operations:

```sh
/bin/busybox --install -s /bin

mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

echo " * enabling eth0"
ip link set eth0 up || rescue_shell
sleep 2

echo " * requesting dhcp"
udhcpc || rescue_shell
sleep 2

echo " * setting time from ntp"
ntpd -q -p pool.ntp.org || rescue_shell
sleep 2

echo " * mounting mmcblk0p1"
mkdir -p /mnt/mmc0p1
mount -t ext4 /dev/mmcblk0p1 /mnt/mmc0p1

perform_update 2>&1 | tee update.log

mkdir -p /mnt/ro
mkdir -p /mnt/rw
mkdir -p /mnt/overlay

echo " * mounting squashfs to /mnt/ro"
mount -t squashfs /mnt/mmc0p1/filesystem.squashfs /mnt/ro

storage=$(egrep -o 'storage[^ ]*' /proc/cmdline | sed 's/storage=//')
echo " * mounting $storage to /mnt/rw"
mount -t btrfs $storage /mnt/rw

mkdir -p /mnt/rw/upper
mkdir -p /mnt/rw/work
echo " * mounting overlayfs to /mnt/overlay"
mount -t overlay -o lowerdir=/mnt/ro,upperdir=/mnt/rw/upper,workdir=/mnt/rw/work overlay /mnt/overlay

mount --move /dev /mnt/overlay/dev || rescue_shell
umount /proc /sys
echo " * switching root"
exec switch_root /mnt/overlay /sbin/init
```


## Acknowledgements

Copyright (C) 2017-2018 by Dyne.org foundation, Amsterdam

Designed, written and maintained by Ivan J. <parazyd@dyne.org>

with help from Merlijn Wajer and Denis Roio

This project has received funding from the European Union’s Horizon
2020 research and innovation programme under grant agreement
nr. 732546

This  source code  is free  software; you  can redistribute  it and/or
modify it  under the terms of  the GNU Public License  as published by
the Free Software Foundation; either  version 3 of the License, or (at
your option) any later version.

This source  code is distributed in  the hope that it  will be useful,
but  WITHOUT  ANY  WARRANTY;  without  even the  implied  warranty  of
MERCHANTABILITY or FITNESS FOR  A PARTICULAR PURPOSE.  Please refer to
the GNU Public License for more details.

You should have  received a copy of the GNU  Public License along with
this source  code; if not,  write to: Free Software  Foundation, Inc.,
675 Mass Ave, Cambridge, MA 02139, USA.
