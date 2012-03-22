if [ $# -lt 2 ]; then
	panic "Usage:  $0 release $CONFIG [branch [ref]]"
fi

BRANCH=$3
[ -z "$BRANCH" ] && BRANCH="master"

REF=$4
[ -z "$REF" ] && REF="$BRANCH"

echo $REF > $RELEASES/$BRANCH || exit 1
