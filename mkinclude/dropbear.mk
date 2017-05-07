DROPBEAR_VERSION = 2016.74

src/dropbear-$(DROPBEAR_VERSION).tar.bz2: | src
	wget https://matt.ucc.asn.au/dropbear/releases/dropbear-$(DROPBEAR_VERSION).tar.bz2 -O $@

initramfs/sbin/dropbear initramfs/bin/scp: src/dropbear-$(DROPBEAR_VERSION).tar.bz2 opt/kernel/.dirstamp $(CC_DIRSTAMP)
ifeq ($(uname_s),Darwin)
	$(docker-make)
else
	mkdir -p ./initramfs/sbin ./initramfs/bin
	tar -C ./build -xf ./src/dropbear-$(DROPBEAR_VERSION).tar.bz2
	export CC=$(CC) CFLAGS="-I$(CURDIR)/opt/kernel/include -O2" ; \
		cd ./build/dropbear-$(DROPBEAR_VERSION) && \
		./configure --prefix=$(CURDIR)/build/dropbear --host=$$(uname -m) \
			--disable-zlib --disable-lastlog --disable-wtmp && \
		make PROGRAMS="dropbear scp" && \
		make PROGRAMS="dropbear scp" install
	cp -p ./build/dropbear/sbin/dropbear ./initramfs/sbin/
	cp -p ./build/dropbear/bin/scp ./initramfs/bin/
endif
