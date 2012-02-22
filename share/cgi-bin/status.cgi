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
export ws=$($GITCE workspace $CONFIG)

# general output
echo "{"

# logged in user (or empty if not available)
echo "    \"user\": \"$REMOTE_USER\","

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
ls $ws/heads | while read head; do
	commit=$(cat $ws/heads/$head)
	number=$(($(cat $ws/builds/$head/number) - 1))

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$head\","
	echo "            \"commit\": \"$commit\","
	echo "            \"number\": \"$number\""
	echo "        }"
done
echo "    ],"

# output broken branches
echo "    \"broken\": ["
first=1
$GITCE current $CONFIG | grep "broken" | while read line; do
	branch=$(echo $line | awk '{print $2}')
	number=$(echo $line | awk '{print $3}')
	commit=$(echo $line | awk '{print $4}')
	from=$(echo $line | awk '{print $5}')

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$branch\","
	echo "            \"number\": \"$number\","
	echo "            \"commit\": \"$commit\","
	echo "            \"authors\": [$(git_authors_list $ws $from $commit)]"
	echo "        }"
done
echo "    ],"

# output currently running branch
echo "    \"running\": ["
first=1
$GITCE current $CONFIG | grep "running" | while read line; do
	branch=$(echo $line | awk '{print $2}')
	number=$(echo $line | awk '{print $3}')
	commit=$(echo $line | awk '{print $4}')
	from=$(echo $line | awk '{print $5}')

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$branch\","
	echo "            \"number\": \"$number\","
	echo "            \"commit\": \"$commit\","
	echo "            \"message\": \"$(git --git-dir=$ws/repository log --format='%ar: (%h) %s' "$commit^..$commit")\","
	echo "            \"authors\": [$(git_authors_list $ws $from $commit)]"
	echo "        }"
done
echo "    ]"

echo "}"

# OUTPUT END
