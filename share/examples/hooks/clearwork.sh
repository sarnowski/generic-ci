#!/bin/sh
if [ -d $GITCE_BUILD_DIR ]; then
	echo "Clearing work directory..."
	rm -r $GITCE_BUILD_DIR/*
fi
