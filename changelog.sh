#!/bin/sh
echo "generic-ci ChangeLog"
echo
git --git-dir=$(dirname $0)/.git for-each-ref --sort='-authordate' --format='%(refname:short)' refs/tags | while read tag; do
	if [ -z "$last_tag" ]; then
		last_tag=$tag
		continue
	fi

	echo "$last_tag"
	git --git-dir=$(dirname $0)/.git log --format="%s [%an]" $tag..$last_tag | while read line; do
		echo "    - $line"
	done

	last_tag=$tag
	echo
done

