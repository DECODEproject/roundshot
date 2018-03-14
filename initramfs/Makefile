# roundshot
# See LICENSE file for copyright and license details

include config.mk

all: dirs busybox gnupg btrfs initramfs.cpio.bz2

dirs:
	mkdir -p build
	cd build && mkdir -p bin dev etc lib mnt/root proc root sys tmp usr var/run
	cp -a /dev/console build/dev
	cp -a /dev/null build/dev
	cp -a /dev/random build/dev
	cp -a /dev/tty build/dev
	cp -a /dev/urandom build/dev
	cp -ra skel/* build/
	cp -ra skel/.gnupg build/

busybox:
ifeq ($(BUSYBOX),1)
	wget -c $(BUSYBOX_URL)
	tar xf $(shell basename $(BUSYBOX_URL))
	cp -f busybox.config $(shell basename -s .tar.bz2 $(BUSYBOX_URL))/.config
	export PATH="$(TC_PATH)/bin:$(PATH)" && \
		cd $(shell basename -s .tar.bz2 $(BUSYBOX_URL)) && \
		make -j9 ARCH=arm CROSS_COMPILE=$(TC_NAME) CFLAGS="-Os -static" LDFLAGS="-s -static" && \
		cp -f busybox $(PWD)/build/bin
endif

gnupg:
ifeq ($(GNUPG),1)
	wget -c $(GNUPG_URL)
	ar x $(shell basename $(GNUPG_URL))
	tar xf data.tar.xz
	cp -f usr/bin/gpgv-static $(PWD)/build/bin/gpgv
	rm -rf usr data.tar.xz control.tar.gz debian-binary
endif

btrfs:
ifeq ($(GNUPG),1)
	wget -c $(BTRFS_URL)
	wget -c $(BTRFSMKFS_URL)
	mv btrfs.static $(PWD)/build/bin/btrfs
	mv mkfs.btrfs.static $(PWD)/build/bin/mkfs.btrfs
	chmod 755 $(PWD)/build/bin/btrfs
	chmod 755 $(PWD)/build/bin/mkfs.btrfs
endif

initramfs.cpio.bz2:
	cd build && \
		find . -print0 | cpio --null -ov --format=newc | bzip2 --best > $(PWD)/$@

clean:
	rm -rf build busybox-* gpgv-*

distclean: clean
	rm -f initramfs.cpio.bz2
