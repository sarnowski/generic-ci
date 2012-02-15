if [ $# -lt 2 ]; then
	panic "Usage:  $0 schedule-release $2 [branch [ref]]"
fi

BRANCH=$3
[ -z "$BRANCH" ] && BRANCH="master"

REF=$4
[ -z "$REF" ] && REF="HEAD"

mkdir -p $RELEASES
echo $REF > $RELEASES/$BRANCH || exit 1
echo "Release for $BRANCH (on ref $REF) scheduled."
