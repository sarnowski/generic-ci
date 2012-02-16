#!/bin/sh

. $(pwd)/init.sh

# HTTP HEADER STAT

echo "Content-Type: text/plain"

echo
# HTTP HEADER END


# OUTPUT START
$GITCE version
