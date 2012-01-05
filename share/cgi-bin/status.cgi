#!/bin/sh

. $(pwd)/init.sh


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

# general output
echo "{"

# output next builds
echo "    \"next\": ["
first=1
$GITCE status $CONFIG | grep -v "deleted" | while read line; do
	branch=$(echo $line | awk '{print $2}')
	commit=$(echo $line | awk '{print $3}')

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$branch\","
	echo "            \"commit\": \"$commit\""
	echo "        }"
done
echo "    ],"

# output active branches
echo "    \"active\": ["
first=1
ws=$($GITCE workspace $CONFIG)
ls $ws/heads | while read head; do
	commit=$(cat $ws/heads/$head)

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$head\","
	echo "            \"commit\": \"$commit\""
	echo "        }"
done
echo "    ]"


echo "}"

# OUTPUT END
