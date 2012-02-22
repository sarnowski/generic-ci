# find gitce command
if [ -f $(dirname $0)/../../gitce ]; then
	GITCE=$(dirname $0)/../../gitce
elif [ -f /usr/local/bin/gitce ]; then
	GITCE=/usr/local/bin/gitce
else
	echo "Cannot find gitce command!" >&2
	exit 1
fi

# helper functions
# git_authos /dir/to/repo.git from_sha1 to_sha1
git_authors_list() {
	first=1
	range="$2..$3"
	[ -z "$3" ] && range=$2
	git --git-dir=$1/repository log --format="%ae|%an" $range | sort | uniq | while read line; do
		email=$(echo $line | cut -d'|' -f1)
		author=$(echo $line | cut -d'|' -f2- | sed 's/"/\\"/g')

		if [ $first -eq 0 ]; then
			echo ","
		else
			first=0
		fi

		echo "{\"name\": \"$author\", \"email\": \"$email\"}"
	done
}


