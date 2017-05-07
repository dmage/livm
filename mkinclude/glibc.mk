GLIBC_VERSION = 2.25

CC_DIRSTAMP =
CC = gcc

src/glibc-$(GLIBC_VERSION).tar.xz: | src
	wget https://ftp.gnu.org/gnu/glibc/glibc-$(GLIBC_VERSION).tar.xz -O $@

opt/glibc/.dirstamp: src/glibc-$(GLIBC_VERSION)/.dirstamp opt/kernel/.dirstamp
ifeq ($(uname_s),Darwin)
	$(docker-make)
else
	mkdir -p ./build/glibc ./opt/glibc
	cd ./build/glibc && \
		./../../src/glibc-$(GLIBC_VERSION)/configure \
			--prefix=/usr \
			--with-headers=$(CURDIR)/opt/kernel/include --enable-kernel=4.4 \
			--disable-nscd \
			CFLAGS='-O2' && \
		make -j$(CPUS) && \
		make install DESTDIR=$(CURDIR)/opt/glibc
	touch $@
endif

initramfs/lib:
	mkdir $@

# $(call glibc-lib,libc,libc.so.6)
GLIBC_LIBS=
define glibc-lib
initramfs/lib/$(2): opt/glibc/.dirstamp | initramfs/lib
	cp ./opt/glibc/lib64/$(1)-$$(GLIBC_VERSION).so $$@
GLIBC_LIBS+=initramfs/lib/$(2)
endef

$(eval $(call glibc-lib,libc,libc.so.6))
$(eval $(call glibc-lib,libcrypt,libcrypt.so.1))
$(eval $(call glibc-lib,libm,libm.so.6))
$(eval $(call glibc-lib,libnss_dns,libnss_dns.so.2))
$(eval $(call glibc-lib,libnss_files,libnss_files.so.2))
$(eval $(call glibc-lib,libutil,libutil.so.1))

$(eval $(call glibc-lib,ld,ld-linux-x86-64.so.2))

share/boot/initrd.img: $(GLIBC_LIBS)
