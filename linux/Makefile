# roundshot
# See LICENSE file for copyright and license details

include config.mk

all: linux-$(LINUX_TYPE) build-$(LINUX_TYPE) install

linux-vanilla:
	git clone $(LINUX_URL_VANILLA) -b $(LINUX_VERSION_VANILLA) $@

linux-grsec:
	git clone $(LINUX_URL_GRSEC) -b $(LINUX_VERSION_GRSEC) $@

build-$(LINUX_TYPE):
	cp -f $(LINUX_TYPE).config linux-$(LINUX_TYPE)/.config
	@export PATH="$(TC_PATH)/bin:$(PATH)" && \
		cd linux-$(LINUX_TYPE) && \
		git pull && \
		make ARCH=arm CROSS_COMPILE=$(TC_NAME) oldconfig && \
		make ARCH=arm CROSS_COMPILE=$(TC_NAME) -j9 zImage dtbs modules && \
		make ARCH=arm CROSS_COMPILE=$(TC_NAME) INSTALL_MOD_PATH=$(PWD)/build \
			INSTALL_MOD_STRIP=1 modules_install

install:
	@mkdir -p build
	cp -f linux-$(LINUX_TYPE)/arch/arm/boot/zImage build/zImage
	cp -f linux-$(LINUX_TYPE)/arch/arm/boot/dts/$(ARM_DTB) build/$(ARM_DTB)

clean:
	rm -rf linux-*

distclean: clean
	rm -rf build
