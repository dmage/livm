share/boot/initrd.img: \
	initramfs/bin/busybox \
	initramfs/bin/scp \
	initramfs/etc/udhcpc/default.script \
	initramfs/sbin/dropbear

share/boot/initrd.img: $(shell find ./initramfs -type f)
	mkdir -p `dirname $@`
	cd initramfs && find . | cpio -o -H newc | gzip -1 > ../$@

initrd-clean:
	rm -vf initramfs/lib/libc.so initramfs/lib/ld-linux-x86-64.so.2 initramfs/lib/ld-musl-x86_64.so.1

.PHONY: initrd-clean
