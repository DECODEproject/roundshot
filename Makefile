# roundshot
# See LICENSE file for copyright and license details

all:
	cd toolchain && make
	cd initramfs && make
	cd linux     && make
	cp -ra linux/build/lib squashfs/overlay
	cd squashfs && make
	cd u-boot   && make

dist: all
	mkdir -p dist
	cp -fra linux/build dist/linux-build
	cp -fra initramfs/initramfs.cpio.bz2 dist
	cp -f squashfs/filesystem.squashfs dist
	cp -f u-boot/build/u-boot-sunxi-with-spl.bin dist
	cp -f misc/prepimg.sh dist
	cd dist && ./prepimg.sh

clean:
	make -C toolchain clean
	make -C initramfs clean
	make -C linux     clean
	make -C squashfs  clean
	make -C u-boot    clean

distclean:
	make -C toolchain distclean
	make -C initramfs distclean
	make -C linux     distclean
	make -C squashfs  distclean
	make -C u-boot    distclean

mrproper: clean distclean
	rm -rf dist
