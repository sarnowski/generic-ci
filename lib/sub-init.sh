SOURCE=$3
[ -z "$SOURCE" ] && panic "Usage:  $0 init <configuration> <source>"

if [ ! -d $REPOSITORY ]; then
	mkdir -p $(dirname $REPOSITORY)
	git clone --mirror $SOURCE $REPOSITORY >/dev/null
	result=$?
	if [ $result -ne 0 ]; then
		rm -rf $REPOSITORY
	fi
	exit $result
else
	echo "Configuration already initialized!" >&2
	exit 1
fi
