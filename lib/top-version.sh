version_file=$DOC/VERSION
if [ -f $version_file ]; then
	cat $version_file
else
	echo "development"
fi
exit 0
