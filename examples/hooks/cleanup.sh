#!/bin/sh
if [ -d $GENCI_BUILD_WORK_DIR ]; then
	echo "Cleaning work directory..."
	rm -r $GENCI_BUILD_WORK_DIR
fi
