version_file=$DOC/VERSION
git_dir=$(dirname $GENCI)/.git

which git >/dev/null 2>&1
git_exists=$?

if [ $git_exists -eq 0 ] && [ -d $git_dir ]; then
	git --git-dir=$git_dir describe --tags
	exit 0
elif [ -f $version_file ]; then
	cat $version_file
	exit 0
else
	echo "unknown"
	exit 1
fi
