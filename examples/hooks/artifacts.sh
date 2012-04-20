#!/bin/sh

if [ ! -z "$ARTIFACTS" ] && [ -d $GENCI_BUILD_WORK_DIR ]; then
	ARTIFACTS_DIR=$GENCI_BUILD_DIR/artifacts
	mkdir -p $ARTIFACTS_DIR

	cd $GENCI_BUILD_WORK_DIR

	echo "Collecting artifacts..."
	for artifact in $ARTIFACTS; do
		if [ -d "$artifact" ]; then
			echo "  dir  $artifact"
			cp -r "$artifact" $ARTIFACTS_DIR
		elif [ -f "$artifact" ]; then
			echo "  file $artifact"
			cp "$artifact" $ARTIFACTS_DIR
		else
			echo "  glob $artifact"
			for file in $(ls $artifact); do
				if [ -d "$file" ]; then
					echo "    dir  $file"
					mkdir -p $ARTIFACTS_DIR/$file
				else
					echo "    file $file"
					mkdir -p $(dirname $ARTIFACTS_DIR/$file)
					cp $file $ARTIFACTS_DIR/$file
				fi
			done
		fi
	done

	rmdir $ARTIFACTS_DIR 2>&1
	exit 0
else
	echo "Error: cannot collect artifacts, no artifacts configured or work directory vanished!" >&2
	exit 1
fi
