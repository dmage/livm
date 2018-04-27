## livm — Linux in a Virtual Machine

LiVM is a minimal Linux in a Virtual Machine. It is created to automate testing of low-level utilities like setfont.

It consists of:

1.  [The Linux Kernel](https://www.kernel.org),
2.  [The GNU C Library](https://www.gnu.org/software/libc/),
3.  [Busybox](https://www.busybox.net),
4.  [The Dropbear SSH Server](https://matt.ucc.asn.au/dropbear/dropbear.html).

There is nothing more inside, but glibc and scp is a good foundation to bootstrap anything you want. :)

### Installation

    $ wget https://github.com/dmage/livm/releases/download/v0.2.0/livm-0.2.0.tar.gz
    $ tar -xf livm-0.2.0.tar.gz -C /usr/local

### Usage

    $ livm start ./vm1
    $ touch foo && livm scpto ./vm1 ./foo .
    $ livm ssh ./vm1 'exec >/dev/tty0; clear; ls -la'
    $ livm screenshot ./vm1 screenshot.ppm
    $ livm stop ./vm1

### Building from the source code

    $ if [ "$(uname -s)" == "Darwin" ]; then eval `docker-machine env`; fi
    $ make
    $ ./bin/livm start ./vm1
    $ ./bin/livm ssh ./vm1
    $ ./bin/livm stop ./vm1

### Error: could not set up host forwarding rule 'tcp:127.0.0.1:2222-:22'

By default, it binds to the host port 2222. If it's already in use by another program or you want to run multiple machines simultaneously, you can choose a different port:

    $ LIVM_SSH_PORT=8022 livm start ./vm

### Can I run it on macOS?

Yes, all you need is a POSIX shell and [QEMU](http://download.qemu-project.org/qemu-doc.html).

### Can I build it on macOS?

Yes, but you need [Docker](https://www.docker.com).

### How to get into a virtual machine if dropbear failed to start?

    $ LIVM_DEBUG=1 livm start ./vm

### How to enable a framebuffer console?

    $ LIVM_VGA=0x303 livm start ./vm

### How to get possible values for the VGA parameter?

    $ LIVM_DEBUG=1 LIVM_VGA=ask livm start ./vm

### How to reconfigure the kernel?

    $ make kernel-menuconfig
    $ make

### How to upgrade the kernel?

Upgrading to X.Y:

    $ sed -i.bak -e 's/^\(KERNEL_VERSION =\).*/\1 X.Y/' ./mkinclude/kernel.mk
    $ make kernel-menuconfig KERNEL_MENUCONFIG=oldconfig
    $ make share/boot/vmlinuz
