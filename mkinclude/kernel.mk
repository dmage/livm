KERNEL_MENUCONFIG ?= menuconfig
KERNEL_VERSION = 4.11

src/linux-$(KERNEL_VERSION).tar.xz: | src
	wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz -O $@

kernel-menuconfig: src/linux-$(KERNEL_VERSION)/.dirstamp
	touch .kernel-config
ifeq ($(uname_s),Darwin)
	$(docker-make)
else
	mkdir -p ./build/linux
	cp ./.kernel-config ./build/linux/.config
	cd ./src/linux-$(KERNEL_VERSION) && make -j$(CPUS) O=$(CURDIR)/build/linux $(KERNEL_MENUCONFIG)
	# If we inside the docker container, we can replace only the content of the .kernel-config file, but not the file itself.
	cat ./build/linux/.config >.kernel-config
endif

share/boot/vmlinuz: src/linux-$(KERNEL_VERSION)/.dirstamp .kernel-config
ifeq ($(uname_s),Darwin)
	$(docker-make)
else
	mkdir -p ./build/linux
	cp ./.kernel-config ./build/linux/.config
	cd ./src/linux-$(KERNEL_VERSION) && make -j$(CPUS) O=$(CURDIR)/build/linux
	mkdir -p ./share/boot
	cp ./build/linux/arch/x86/boot/bzImage ./share/boot/vmlinuz
endif

opt/kernel/.dirstamp: src/linux-$(KERNEL_VERSION)/.dirstamp
ifeq ($(uname_s),Darwin)
	$(docker-make)
else
	mkdir -p ./build/linux ./opt/kernel
	cd ./src/linux-$(KERNEL_VERSION) && make headers_install O=$(CURDIR)/build/linux INSTALL_HDR_PATH=$(CURDIR)/opt/kernel
	touch ./opt/kernel/.dirstamp
endif

.PHONY: kernel-menuconfig
