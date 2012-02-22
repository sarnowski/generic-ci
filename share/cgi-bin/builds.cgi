#!/bin/sh

. $(dirname $0)/init.sh

# check for the configuration parameter
if [ -z "$QUERY_STRING" ]; then
	echo "No configuration name given!"
	exit 0
fi
CONFIG=$QUERY_STRING

# basic var
export ws=$($GITCE workspace $CONFIG)


# HTTP HEADER STAT

echo "Content-Type: application/json"

echo
# HTTP HEADER END


# OUTPUT START
first_branch=1

echo "{"
for branch in $(ls $ws/builds); do
	if [ $first_branch -eq 0 ]; then
		echo "    ,"
	else
		first_branch=0
		echo "     "
	fi

	echo "\"$branch\": ["
	first_build=1
	last_commit=
	next_number=$(cat $ws/builds/$branch/number)
	number=0
	while [ $number -lt $next_number ]; do
		prefix="$ws/builds/$branch/build/$number"

		[ ! -f $prefix.sha1 ] && continue

		commit=$(cat $prefix.sha1)
		result=
		[ -f $prefix.result ] && result=$(cat $prefix.result)
		time=$(stat -c %Y $prefix.sha1)

		if [ $first_build -eq 0 ]; then
			echo "    ,"
		else
			first_build=0
			echo "     "
		fi

		echo "        {"
		echo "            \"number\": \"$number\","
		echo "            \"commit\": \"$commit\","
		if [ -f $prefix.exec ]; then
			echo "            \"exec\": \"$(cat $prefix.exec | sed 's/"/\\"/g')\","
		fi
		echo "            \"result\": \"$result\","
		echo "            \"time\": \"$time\","
		echo "            \"authors\": [$(git_authors_list $ws $last_commit $commit)]"
		echo "        }"

		last_commit=$commit
		number=$(($number + 1))
	done
	echo "    ]"
done
echo "}"


# OUTPUT END
