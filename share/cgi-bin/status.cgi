#!/bin/sh

. $(dirname $0)/init.sh

# HTTP HEADER STAT

echo "Content-Type: application/json"

echo
# HTTP HEADER END


# OUTPUT START

# check for the configuration parameter
if [ -z "$QUERY_STRING" ]; then
	echo "No configuration name given!"
	exit 0
fi
CONFIG=$QUERY_STRING

# basic var
export ws=$WORKS/$CONFIG

# general output
echo "{"

# logged in user (or empty if not available)
echo "    \"user\": \"$REMOTE_USER\","

# output next builds
echo "    \"branches\": ["
first=1
$GITCE status $CONFIG | while read line; do
	status=$(echo $line | awk '{print $1}')
	branch=$(echo $line | awk '{print $2}')
	action=$(echo $line | awk '{print $3}')
	number=$(echo $line | awk '{print $4}')
	running=$(echo $line | awk '{print $5}')

	if [ -z "$running" ]; then
		running="false"
	else
		running="true"
	fi


	commit=$(cat $ws/builds/$branch/build/$number/sha1)
	if [ -f $ws/builds/$branch/build/$(($number - 1))/sha1 ]; then
		from=$(cat $ws/builds/$branch/build/$(($number - 1))/sha1)
	fi

	message=$(git --git-dir=$ws/repository log --format='%ar: (%h) %s' "$commit^..$commit" | head -n 1)

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$branch\","
	echo "            \"status\": \"$status\","
	echo "            \"action\": \"$action\","
	echo "            \"number\": $number,"
	echo "            \"running\": $running,"
	echo "            \"commit\": \"$commit\","
	echo "            \"message\": \"$(echo $message | sed 's/\"/\\\"/g')\","
	echo "            \"authors\": [$(git_authors_list $ws $from $commit)]"
	echo "        }"
done
echo "    ]"

echo "}"

# OUTPUT END
