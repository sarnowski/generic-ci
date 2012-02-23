#!/bin/sh

. $(dirname $0)/init.sh

# HTTP HEADER STAT

echo "Content-Type: application/json"

echo
# HTTP HEADER END


# OUTPUT START
first=1

echo "["
for config in $(ls $CONF); do
	if [ -d $CONF/$config ]; then
		continue
	fi

	if [ $first -eq 0 ]; then
		echo "    ,"
	else
		first=0
		echo "     "
	fi

	owner=$(stat -c "%U" $WORKS/$config/releases)
	if [ $(id -un) = "$owner" ]; then
		releasable="true"
	else
		releasable="false"
	fi

	echo "{"
	echo "    \"config\": \"$config\","
	echo "    \"releasable\": $releasable"
	echo "}"
done
echo "]"


# OUTPUT END
