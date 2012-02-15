#!/bin/sh

. $(pwd)/init.sh

# HTTP HEADER STAT

echo "Content-Type: application/json"

echo
# HTTP HEADER END


# OUTPUT START

# check for the configuration parameter
if [ -z "$QUERY_STRING" ]; then
	echo '{"result":null,"error":"no parameters"}'
	exit 0
fi
RELEASE=$QUERY_STRING

# parse branch and number
config=$(echo $RELEASE | cut -d'/' -f1)
branch=$(echo $RELEASE | cut -d'/' -f2)
ref=$(echo $RELEASE | cut -d'/' -f3)

# check release dir
ws=$($GITCE workspace $config)
owner=$(stat -c "%U" $ws/releases)
if [ $(id -un) != "$owner" ]; then
	echo '{"result":null,"error":"releases dir does not exist or does not match user"}'
	exit 0
fi

# schedule release
result=$($GITCE schedule-release $config $branch $ref | sed 's/"/\\"/g')
echo "{\"result\":\"$result\",\"error\":null}"
