#!/bin/sh
cd $(dirname $0)
root=$(pwd)

# resolve version
GIT_DIR=.git
[ ! -z "$GENCI_REPOSITORY" ] && GIT_DIR=$GENCI_REPOSITORY

REF=$GENCI_BUILD_SHA1
[ -z "$REF" ] && REF="HEAD"

VERSION=$(git --git-dir=$GIT_DIR describe --tags $REF)
if [ -z "$VERSION" ]; then
	echo "Cannot retrieve version; aborting release!" >&2
	exit 1
fi

# generate user tarball
echo "Building user tarball..."
git archive --format=tar --prefix="generic-ci-$VERSION/" $REF | gzip -9 > generic-ci-user-$VERSION.tar.gz || exit $?

# a temporary directory for the package
TMP=/tmp/genci-$(date +%s)

# the package structure
mkdir -p $TMP/usr/local/bin
mkdir -p $TMP/usr/local/lib
mkdir -p $TMP/usr/local/share/doc
mkdir -p $TMP/usr/local/share/examples

cp genci $TMP/usr/local/bin

cp -r lib $TMP/usr/local/lib/genci

cp -r doc $TMP/usr/local/share/doc/genci
cp README $TMP/usr/local/share/doc/genci
echo $VERSION > $TMP/usr/local/share/doc/genci/VERSION

cp -r examples $TMP/usr/local/share/examples/genci

# build server tarball
echo "Building server tarball..."
TAR=generic-ci-server-$VERSION.tar.gz
tar czf $TAR -C $TMP usr || exit $?

# build openbsd package
if [ "$(uname)" = "OpenBSD" ] && [ -d /usr/ports/infrastructure ] && [ $(id -u) -eq 0 ]; then
	echo "Building OpenBSD package..."

	if [ ! -z "$(echo $VERSION | grep '\-g')" ]; then
		OVERSION=$(echo $VERSION | sed 's/-.*//')
		echo "Rewriting version to $OVERSION"
	else
		OVERSION=$VERSION
	fi

	mkdir -p $TMP/devel/generic-ci-openbsd
	sed "s/VERSION/$OVERSION/g" openbsd/Makefile > $TMP/devel/generic-ci-openbsd/Makefile
	mkdir -p $TMP/devel/generic-ci-openbsd/pkg
	cp README $TMP/devel/generic-ci-openbsd/pkg/DESCR

	git archive --format=tar --prefix="generic-ci-openbsd-$OVERSION/" $REF | gzip -9 > /usr/ports/distfiles/generic-ci-openbsd-$OVERSION.tar.gz || exit $?

	export PORTSDIR_PATH=/usr/ports:$TMP
	cd $TMP/devel/generic-ci-openbsd
	make clean || exit $?
	make makesum || exit $?
	make fake || exit $?
	make plist || exit $?
	make package || exit $?
	cp /usr/ports/packages/no-arch/generic-ci-openbsd-$OVERSION.tgz $root
	make clean || exit $?

	cd $root
else
	echo "Skipping OpenBSD package..."
fi

# build debian package if possible
which dpkg-deb >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Building Debian package..."
	cp -r DEBIAN $TMP
	sed "s/#VERSION#/$VERSION/g" -i $TMP/DEBIAN/control
	DEB=generic-ci-$VERSION-all.deb
	fakeroot dpkg-deb -b $TMP $DEB > /dev/null || exit $?
else
	echo "Skipping Debian package..."
fi

# cleanup
rm -rf $TMP
