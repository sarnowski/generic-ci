#!/bin/sh
cd $(dirname $0)

# resolve version
GIT_DIR=.git
[ ! -z "$GENCI_REPOSITORY" ] && GIT_DIR=$GENCI_REPOSITORY

VERSION=$(git --git-dir=$GIT_DIR describe --tags $GENCI_BUILD_SHA1)

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


# build tarball
echo "Building tarball..."
TAR=generic-ci-$VERSION.tar.gz
tar czf $TAR -C $TMP usr || exit $?

# build debian package if possible
which dpkg-deb >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Building debian package..."
	cp -r DEBIAN $TMP
	sed "s/#VERSION#/$VERSION/g" -i $TMP/DEBIAN/control
	DEB=generic-ci-$VERSION-all.deb
	fakeroot dpkg-deb -b $TMP $DEB > /dev/null || exit $?
else
	echo "Skipping debian package..."
fi

# cleanup
rm -rf $TMP
