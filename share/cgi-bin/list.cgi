#!/bin/sh

# HTTP HEADER STAT

echo "Content-Type: application/json"

echo
# HTTP HEADER END


# OUTPUT START
first=1

echo "["
for config in $(ls /etc/gitce); do
	if [ -d /etc/gitce/$config ]; then
		continue
	fi

	if [ $first -eq 0 ]; then
		echo "    ,"
	else
		first=0
		echo "     "
	fi

	echo "\"$config\""
done
echo "]"


# OUTPUT END
