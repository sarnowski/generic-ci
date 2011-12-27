#!/bin/sh
cd $(dirname $0)

# resolve version
VERSION=$(git describe --tags)

# a temporary directory for the package
TMP=/tmp/gitce-deb
rm -rf $TMP
mkdir -p $TMP

# the package structure
mkdir -p $TMP/usr/local/bin
cp gitce $TMP/usr/local/bin

mkdir -p $TMP/usr/local/lib
cp -r lib $TMP/usr/local/lib/gitce

mkdir -p $TMP/usr/local/share/gitce
cp README LICENSE $TMP/usr/local/share/gitce

cp -r DEBIAN $TMP
sed "s/#VERSION#/$VERSION/g" -i $TMP/DEBIAN/control

# build the package
fakeroot dpkg-deb -b $TMP gitce-$VERSION-all.deb

# cleanup
#rm -rf $TMP
