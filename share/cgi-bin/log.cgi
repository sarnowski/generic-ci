#!/bin/sh

. $(dirname $0)/init.sh

# HTTP HEADER STAT

echo "Content-Type: text/plain"

echo
# HTTP HEADER END


# OUTPUT START

# check for the configuration parameter
if [ -z "$QUERY_STRING" ]; then
	echo "No configuration name given!"
	exit 0
fi
BUILD=$QUERY_STRING

# parse branch and number
config=$(echo $BUILD | cut -d'/' -f1)
branch=$(echo $BUILD | cut -d'/' -f2)
number=$(echo $BUILD | cut -d'/' -f3)

# get workspace
ws=$($GITCE workspace $config)

# give out log file
cat $ws/builds/$branch/build/$number.log
