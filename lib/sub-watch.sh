# update repository
$GENCI update $CONFIG >/dev/null

# parse status
build=
release=
todo=$($GENCI pending $CONFIG | while read status; do
	action=$(echo $status | cut -d' ' -f1)
	branch=$(echo $status | cut -d' ' -f2)

	# deletions come first and can be done directly
	if [ "$action" = "delete" ]; then
		rm $HEADS/$branch
		rm -f $RELEASES/$branch
		continue
	fi

	# release has top priority
	if [ "$action" = "release" ]; then
		release=$branch
		echo "release $branch"
		break
	fi

	# prefer master build
	if [ "$action" = "build" ]; then
		if [ -z "$build" ]; then
			build=$branch
		elif [ "$branch" = "master" ]; then
			build="master"
			break
		fi
	fi
	echo "build $build"
done)

action=$(echo $todo | cut -d' ' -f1)
branch=$(echo $todo | cut -d' ' -f2)

# nothing todo
[ -z "$action" ] && exit 0

# already working on something?
locked_config
[ $? -eq 0 ] && exit 0

# check if we do normal builds
if [ "$RUN_TESTS" = "no" ] && [ "$action" != "release" ]; then
	exit 0
fi

# set up basics
BRANCH_DIR=$BUILDS/$branch
mkdir -p $BRANCH_DIR

# get the build number
BUILD_NUMBER_FILE=$BRANCH_DIR/number
if [ ! -f $BUILD_NUMBER_FILE ]; then
	BUILD_NUMBER=0
else
	BUILD_NUMBER=$(cat $BUILD_NUMBER_FILE)
fi
BUILD_ID=$branch-$BUILD_NUMBER
BUILD_DIR=$BRANCH_DIR/build/$BUILD_NUMBER
BUILD_LOG=$BUILD_DIR/log

# trigger variables
export GENCI_BUILD_LOG=$BUILD_LOG

# prepare build directory
mkdir -p $BUILD_DIR

if [ "$action" = "release" ]; then
	logger -p "daemon.info" "Starting to release $CONFIG/$BUILD_ID..."

	release_ref=$(cat $RELEASES/$branch)

	nohup $GENCI run $CONFIG --release $branch $release_ref > $BUILD_LOG 2>&1

	rm $RELEASES/$branch
	logger -p "daemon.info" "$CONFIG/$BUILD_ID released."

elif [ "$action" = "build" ]; then
	logger -p "daemon.info" "Starting to test $CONFIG/$BUILD_ID..."

	nohup $GENCI run $CONFIG $branch > $BUILD_LOG 2>&1

	logger -p "daemon.info" "$CONFIG/$BUILD_ID tested."
fi
