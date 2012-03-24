#!/bin/sh

# Example script to set up a chroot environment on OpenBSD.
#
# To run this script, you have to have a group and user called
# "builder" with id 32760. Set up the following configuration
# in your generic-ci config:
#  BUILD_USER=builder
#  CHROOT_SETUP=/path/to/this/chroot-setup.sh
#
# The commands installed here, are nessecary to build generic-ci
# itself. Feel free to copy and modify the script to your needs.

ROOT=$1

echo "Generating chroot environment..."

# helper to easily add files
lnf() {
	for file in $(ls $1); do
		[ -f $ROOT/$file ] && continue

		mkdir -p $(dirname $ROOT/$file)
		cp -p $file $ROOT/$file

		for dep in $(ldd $file 2>/dev/null | awk '{print $7}'); do
			[ -f $dep ] && lnf $dep
		done
	done
}

lnd() {
	for file in $(find $1); do
		[ -f $file ] && lnf $file
	done
}

# /bin
mkdir -p $ROOT/bin
lnf /bin/cat
lnf /bin/chmod
lnf /bin/date
lnf /bin/hostname
lnf /bin/ls
lnf /bin/mkdir
lnf /bin/rm
lnf /bin/sh
lnf /bin/tar
lnf /usr/bin/basename
lnf /usr/bin/cut
lnf /usr/bin/dirname
lnf /usr/bin/env
lnf /usr/bin/grep
lnf /usr/bin/head
lnf /usr/bin/id
lnf /usr/bin/logger
lnf /usr/bin/nohup
lnf /usr/bin/sort
lnf /usr/bin/touch
lnf /usr/bin/uname
lnf /usr/bin/uniq
lnf /usr/bin/wc

# /etc
mkdir -p $ROOT/etc
cat > $ROOT/etc/passwd << "EOF"
root:*:0:0:Charlie &:/root:/bin/sh
builder:*:32760:32760:Build Agent:/home:/bin/sh
EOF
cat > $ROOT/etc/group << "EOF"
wheel:*:0:root
builder:*:32760:builder
EOF
cat > $ROOT/etc/fstab << "EOF"
/ none none defaults
EOF

# /home
mkdir -p $ROOT/home/builder
chown builder:builder $ROOT/home/builder

# /dev
mkdir -p $ROOT/dev
mknod $ROOT/dev/null c 2 2
chmod 0666 $ROOT/dev/null
mknod $ROOT/dev/random c 45 0
mknod $ROOT/dev/stderr c 22 2
chmod 0666 $ROOT/dev/stderr
mknod $ROOT/dev/stdin c 22 0
mknod $ROOT/dev/stdout c 22 1
chmod 0666 $ROOT/dev/stdout
mknod $ROOT/dev/tty c 1 0
chmod 0666 $ROOT/dev/tty
mknod $ROOT/dev/zero c 2 12
chmod 0666 $ROOT/dev/zero

# /tmp
mkdir -p $ROOT/tmp
chmod 0777 $ROOT/tmp

# git
lnf /usr/local/bin/git
lnd /usr/local/libexec/git
lnd /usr/local/share/git-core
cat > $ROOT/home/builder/.gitconfig << "EOF"
[user]
	email = builder@example.com
	name = Builder
EOF
chown builder:builder $ROOT/home/builder/.gitconfig
