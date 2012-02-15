if [ $# -lt 2 ]; then
	panic "Usage:  $0 release $2 [branch [ref]]"
fi

BRANCH=$3
[ -z "$BRANCH" ] && BRANCH="master"

REF=$4
[ -z "$REF" ] && REF="HEAD"

[ -z "$RELEASE_EXECUTABLE" ] && RELEASE_EXECUTABLE=/release.sh

$0 run $2 $BRANCH $REF $RELEASE_EXECUTABLE || exit $?
