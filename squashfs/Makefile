# roundshot
# See LICENSE file for copyright and license details

include config.mk

all: filesystem.squashfs

filesystem.squashfs:
	wget -c $(ROOTFS_URL)
	mkdir -p rootfs
	cd rootfs && tar xf ../$(shell basename $(ROOTFS_URL))
	cp -frav overlay/* rootfs
	mksquashfs rootfs $@ -comp xz

clean:
	rm -rf rootfs overlay/lib/modules $(shell basename $(ROOTFS_URL))

distclean: clean
	rm -f filesystem.squashfs
