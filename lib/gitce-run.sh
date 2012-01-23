BRANCH=$3

if [ -z "$BRANCH" ]; then
	panic "Usage:  $0 run $2 <branch> not given"
fi

# set up basics
BRANCH_DIR=$BUILDS/$BRANCH
mkdir -p $BRANCH_DIR

# get the build number
BUILD_NUMBER_FILE=$BRANCH_DIR/number
if [ ! -f $BUILD_NUMBER_FILE ]; then
	BUILD_NUMBER=0
else
	BUILD_NUMBER=$(cat $BUILD_NUMBER_FILE)
fi
echo $(($BUILD_NUMBER + 1)) > $BUILD_NUMBER_FILE

# set up working directory
BUILD_ID=$BRANCH-$BUILD_NUMBER
BUILD_DIR=$BRANCH_DIR/build/$BUILD_NUMBER
BUILD_SHA1=$BUILD_DIR.sha1
BUILD_RESULT=$BUILD_DIR.result
mkdir -p $BUILD_DIR

echo "Build $BUILD_ID"
date

# get the real git hash
SHA1=$($GIT show --pretty=oneline $BRANCH | head -1 | cut -d' ' -f1)
echo $SHA1 > $BUILD_SHA1

# check out files
echo "Preparing build directory..."
$GIT archive --format=tar $SHA1 | tar x -C $BUILD_DIR

# publish some variables about the build
export GITCE_CONFIG=$CONFIG
export GITCE_CONFIG_DIR=$WORK_DIR
export GITCE_REPOSITORY=$REPO
export GITCE_BRANCH=$BRANCH
export GITCE_BRANCH_DIR=$BRANCH_DIR
export GITCE_BUILD_ID=$BUILD_ID
export GITCE_BUILD_NUMBER=$BUILD_NUMBER
export GITCE_BUILD_SHA1=$SHA1
export GITCE_BUILD_DIR=$BUILD_DIR
export GITCE_BUILD_USER=$BUILD_USER

# trigger pre hooks
TRIGGER_PRE_DIR=$CONFIG_DIR/$CONFIG-pre.d
export GITCE_PHASE="pre"
if [ -d $TRIGGER_PRE_DIR ]; then
	for trigger in $(ls $TRIGGER_PRE_DIR); do
		if [ -d $TRIGGER_PRE_DIR/$trigger ]; then
			$TRIGGER_PRE_DIR/$trigger/trigger.sh
		else
			$TRIGGER_PRE_DIR/$trigger
		fi
	done
fi

# run the script
[ -z "$TEST_EXECUTABLE" ] && TEST_EXECUTABLE=/test.sh
TEST_BIN=$BUILD_DIR$TEST_EXECUTABLE

if [ -f $TEST_BIN ]; then
	if [ $(id -u) -eq 0 ] && [ ! -z "$BUILD_USER" ]; then
		echo "Running build script $TEST_BIN as $BUILD_USER..."
		chown -R $BUILD_USER $BUILD_DIR
		su -p -c "$TEST_BIN" $BUILD_USER
		RESULT=$?
	else
		echo "Running build script $TEST_BIN..."
		$TEST_BIN
		RESULT=$?
	fi
else
	echo "$TEST_BIN not found!" >&2
	RESULT=100
fi


# the result
echo $RESULT > $BUILD_RESULT
echo $SHA1 > $HEADS/$BRANCH
echo "Return code: $RESULT"
export GITCE_BUILD_RESULT=$RESULT

# trigger post hooks
TRIGGER_POST_DIR=$CONFIG_DIR/$CONFIG-post.d
export GITCE_PHASE="post"
if [ -d $TRIGGER_POST_DIR ]; then
	for trigger in $(ls $TRIGGER_POST_DIR); do
		if [ -d $TRIGGER_POST_DIR/$trigger ]; then
			$TRIGGER_POST_DIR/$trigger/trigger.sh
		else
			$TRIGGER_POST_DIR/$trigger
		fi
	done
fi

# for logging
date

# end the run
if [ $RESULT -eq 0 ]; then
	echo "$BUILD_ID successful"
	exit 0
else
	echo "$BUILD_ID failed"
	exit $RESULT
fi
