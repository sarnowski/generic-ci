#!/bin/sh
if [ -d $GITCE_BUILD_DIR ]; then
	echo "Clearing work directory..."
	rm $GITCE_BUILD_DIR/*
fi
