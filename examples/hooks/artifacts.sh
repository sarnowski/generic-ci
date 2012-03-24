#!/bin/sh

ARTIFACTS_DIR=$GENCI_BUILD_DIR/artifacts
mkdir -p $ARTIFACTS_DIR

cd $GENCI_BUILD_WORK_DIR

if [ ! -z "$ARTIFACTS" ] && [ -d $GENCI_BUILD_WORK_DIR ]; then
	echo "Collecting artifacts..."
	for artifact in $ARTIFACTS; do
		for file in $(ls $artifact); do
			echo "  $file"
			mkdir -p $(dirname $ARTIFACTS_DIR/$file)
			cp $file $ARTIFACTS_DIR/$file
		done
	done
fi
