#!/bin/sh
cd $(dirname $0)

# resolve version
GIT_DIR=.git
[ ! -z "$GITCE_REPOSITORY" ] && GIT_DIR=$GITCE_REPOSITORY

VERSION=$(git --git-dir=$GIT_DIR describe --tags $GITCE_BUILD_SHA1)

# a temporary directory for the package
SYS=$(uname)
if [ "$SYS" = "Darwin" ]; then
	TMP=$(mktemp -d -t gitce)
elif [ "$SYS" = "Linux" ]; then
	TMP=$(mktemp -d)
else
	TMP=/tmp/gitce-$(date +%s)
fi

# the package structure
mkdir -p $TMP/usr/local/bin
cp gitce $TMP/usr/local/bin

mkdir -p $TMP/usr/local/lib
cp -r lib $TMP/usr/local/lib/gitce

mkdir -p $TMP/usr/local/share
cp -r share $TMP/usr/local/share/gitce
cp README LICENSE $TMP/usr/local/share/gitce

mkdir -p $TMP/etc/init.d
cp initd.sh $TMP/etc/init.d/gitce-watchers

# build tarball
echo "Building tarball..."
TAR=gitce-$VERSION.tar.gz
tar czf $TAR -C $TMP etc usr || exit $?

# build debian package
which dpkg-deb >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Building debian package..."
	cp -r DEBIAN $TMP
	sed "s/#VERSION#/$VERSION/g" -i $TMP/DEBIAN/control
	DEB=gitce-$VERSION-all.deb
	fakeroot dpkg-deb -b $TMP $DEB > /dev/null || exit $?
else
	echo "Skipping debian package..."
fi

# convert to various other packages
#which alien >/dev/null 2>&1
#if [ $? -eq 0 ]; then
#	echo "Building redhat package..."
#	fakeroot alien --to-rpm $TAR >/dev/null
#else
#	echo "Skipping redhat package..."
#fi

# cleanup
rm -rf $TMP
