# find gitce command
if [ -e $(pwd)/../../gitce ]; then
	GITCE=$(pwd)/../../gitce
elif [ -e $(pwd)/../../gitce ]; then
	GITCE=$(pwd)/../../bin/gitce
else
	echo "Cannot find gitce command!" >&2
	exit 1
fi
