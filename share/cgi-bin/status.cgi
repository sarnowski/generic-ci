#!/bin/sh

. $(pwd)/init.sh

# helper functions
# git_authos /dir/to/repo.git from_sha1 to_sha1
git_authors_list() {
	first=1
	sent=""
	git --git-dir=$ws/repository log --format="%ae|%an" $2..$3 | while read line; do
		if [ $first -eq 0 ]; then
			echo ","
		else
			first=0
		fi
		email=$(echo $line | cut -d'|' -f1)
		author=$(echo $line | cut -d'|' -f2- | sed 's/"/\\"/g')
		if [ -z "$(echo $sent | grep "|$email|")" ]; then
			echo "{\"name\": \"$author\", \"email\": \"$email\"}"
			sent="$sent|$email|"
		fi
	done
}


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
echo "    ],"

# output broken branches
echo "    \"broken\": ["
first=1
$GITCE current $CONFIG | grep "broken" | while read line; do
	branch=$(echo $line | awk '{print $1}')
	commit=$(echo $line | awk '{print $3}')
	from=$(echo $line | awk '{print $4}')

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$branch\","
	echo "            \"commit\": \"$commit\","
	echo "            \"authors\": [$(git_authors_list $CONFIG $from $commit)]"
	echo "        }"
done
echo "    ],"

# output currently running branch
echo "    \"running\": ["
first=1
$GITCE current $CONFIG | grep "running" | while read line; do
	branch=$(echo $line | awk '{print $1}')
	commit=$(echo $line | awk '{print $3}')
	from=$(echo $line | awk '{print $4}')

	if [ $first -eq 0 ]; then
		echo "        ,"
	else
		first=0
	fi

	echo "        {"
	echo "            \"branch\": \"$branch\","
	echo "            \"commit\": \"$commit\","
	echo "            \"message\": \"$(git --git-dir=$ws/repository log --format='%ar: (%h) %s' "$commit^..$commit")\","
	echo "            \"authors\": [$(git_authors_list $CONFIG $from $commit)]"
	echo "        }"
done
echo "    ]"

echo "}"

# OUTPUT END
