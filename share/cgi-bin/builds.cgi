#!/bin/sh

. $(dirname $0)/init.sh

# check for the configuration parameter
if [ -z "$QUERY_STRING" ]; then
	echo "No configuration name given!"
	exit 0
fi
CONFIG=$(echo $QUERY_STRING | cut -d'/' -f1)
BRANCH=$(echo $QUERY_STRING | cut -d'/' -f2)

# basic var
export ws=$WORKS/$CONFIG

# HTTP HEADER STAT

echo "Content-Type: application/json"

echo
# HTTP HEADER END


# OUTPUT START
echo "["
first_build=1
last_commit=
next_number=$(cat $ws/builds/$BRANCH/number)
number=0
while [ $number -lt $next_number ]; do
	prefix="$ws/builds/$BRANCH/build/$number"

	commit=$(cat $prefix/sha1)
	result=
	[ -f $prefix/result ] && result=$(cat $prefix/result)
	if [ $(uname) = "OpenBSD" ]; then
		time=$(stat -f "%c" $prefix/sha1)
	else
		time=$(stat -c %Y $prefix/sha1)
	fi

	if [ $first_build -eq 0 ]; then
		echo "    ,"
	else
		first_build=0
		echo "     "
	fi

	release=
	if [ -f $prefix/release ]; then
		release="true"
	else
		release="false"
	fi

	echo "        {"
	echo "            \"number\": \"$number\","
	echo "            \"commit\": \"$commit\","
	echo "            \"release\": $release,"
	echo "            \"result\": \"$result\","
	echo "            \"time\": \"$time\","
	echo "            \"authors\": [$(git_authors_list $ws $last_commit $commit)]"
	echo "        }"

	last_commit=$commit
	number=$(($number + 1))
done
echo "]"


# OUTPUT END
