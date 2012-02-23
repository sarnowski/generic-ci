GITCE=/usr/local/bin/gitce

if [ ! -f $GITCE ]; then
	echo "No gitce installed for server usage." >&2
	exit 1
fi

CONF=/etc/gitce
WORKS=/var/lib/gitce

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


