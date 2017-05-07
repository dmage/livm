CPUS ?= 3
DESTDIR ?= /usr/local

libc ?= glibc

srctree := $(CURDIR)
uname_s := $(shell uname -s)

define docker-shell
docker build -t livm-fedora ./livm-fedora
docker volume create --name livm-build
docker run --rm -i -t \
	-v livm-build:/srv/build \
	-v "$(CURDIR)/.busybox-config:/srv/.busybox-config" \
	-v "$(CURDIR)/.kernel-config:/srv/.kernel-config" \
	-v "$(CURDIR)/initramfs:/srv/initramfs" \
	-v "$(CURDIR)/opt:/srv/opt" \
	-v "$(CURDIR)/share:/srv/share" \
	-v "$(CURDIR)/src:/srv/src:ro" \
	-v "$(CURDIR)/Makefile:/srv/Makefile:ro" \
	-v "$(CURDIR)/mkinclude:/srv/mkinclude:ro" \
	livm-fedora \
	sh -c $1
endef

define docker-make
$(call docker-shell,"cd /srv && make MAKEFLAGS='$(MAKEFLAGS)' $@")
endef

all: build

docker-sh:
	$(call docker-shell,"cd /srv && exec /bin/bash -il")

mkinclude=\
	_src \
	$(libc) \
	busybox dropbear kernel \
	initrd
include $(foreach f,$(mkinclude),$(srctree)/mkinclude/$(f).mk)

build: share/boot/vmlinuz share/boot/initrd.img

install: build
	install -d $(DESTDIR)/bin $(DESTDIR)/share/livm/boot
	install ./bin/livm $(DESTDIR)/bin/livm
	install ./share/boot/vmlinuz ./share/boot/initrd.img $(DESTDIR)/share/livm/boot

clean:
ifeq ($(uname_s),Darwin)
	docker volume rm livm-build
else
	-rm -rf ./build
endif

.PHONY: docker-sh build install clean
