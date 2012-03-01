# Usage: [--release] [branch [ref]]

# check for release flag
if [ "$3" = "--release" ]; then
	release=1
	shift
else
	release=0
fi

BRANCH=$3
REF=$4

[ -z "$BRANCH" ] && BRANCH="master"
[ -z "$REF" ] && REF="$BRANCH"

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
BUILD_WORK_DIR=$BUILD_DIR/work
BUILD_SHA1=$BUILD_DIR/sha1
BUILD_COMMAND=$BUILD_DIR/command
BUILD_PID=$BUILD_DIR/pid
BUILD_RESULT=$BUILD_DIR/result
BUILD_RELEASE=$release

mkdir -p $BUILD_DIR $BUILD_WORK_DIR

# basic informations
if [ $release -eq 1 ]; then
	echo "Release $BUILD_ID"
else
	echo "Test $BUILD_ID"
fi
date

# mark releases
if [ $release -eq 1 ]; then
	touch $BUILD_DIR/release
fi

# store command
if [ $release -eq 1 ]; then
	COMMAND=$RELEASE_COMMAND
	[ -z "$COMMAND" ] && COMMAND="./release.sh"
else
	COMMAND=$TEST_COMMAND
	[ -z "$COMMAND" ] && COMMAND="./test.sh"
fi
echo $COMMAND > $BUILD_COMMAND

# store pid
echo $$ > $BUILD_PID

# get the real git hash
SHA1=$($GIT show --pretty=oneline "$REF" | head -1 | cut -d' ' -f1)
if [ -z "$SHA1" ]; then
	echo "Failed to resolve ref \"$REF\"!" >&2
	echo "100" > $BUILD_RESULT
	exit 1
fi
echo $SHA1 > $BUILD_SHA1
echo "Build based on $REF ($SHA1)"

# readable informations
TITLE=$($GIT show --format="%s" "$REF" | head -n 1)
echo "Title: $TITLE"

# check out files
echo "Preparing build directory..."
$GIT archive --format=tar $SHA1 | tar -xf- -C $BUILD_WORK_DIR

# publish some variables about the build
export GITCE_CONF=$CONF
export GITCE_CONFIG=$CONFIG
export GITCE_REPOSITORY=$REPOSITORY
export GITCE_BRANCH=$BRANCH
export GITCE_BRANCH_DIR=$BRANCH_DIR
export GITCE_BUILD_ID=$BUILD_ID
export GITCE_BUILD_NUMBER=$BUILD_NUMBER
export GITCE_BUILD_SHA1=$SHA1
export GITCE_BUILD_DIR=$BUILD_DIR
export GITCE_BUILD_WORK_DIR=$BUILD_WORK_DIR
export GITCE_BUILD_USER=$BUILD_USER
export GITCE_BUILD_COMMAND=$BUILD_COMMAND

# set up some variables, su does not set up for us
export HOME=$(grep "^$BUILD_USER:" /etc/passwd | cut -d':' -f6)
export USER=$BUILD_USER
export LOGNAME=$BUILD_USER

# trigger pre hooks
TRIGGER_PRE_DIR=$CONF/$CONFIG-pre.d
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

# run the command
export GITCE_PHASE="build"
export
cd $BUILD_WORK_DIR

if [ $(id -u) -eq 0 ] && [ ! -z "$BUILD_USER" ]; then
	echo "Running build command $COMMAND as $BUILD_USER..."
	chown -R $BUILD_USER $BUILD_WORK_DIR
	su -p -c "$COMMAND" $BUILD_USER
	RESULT=$?
else
	echo "Running build command $COMMAND..."
	$COMMAND
	RESULT=$?
fi

# the result
echo $RESULT > $BUILD_RESULT
echo $SHA1 > $HEADS/$BRANCH
echo "Return code: $RESULT"
export GITCE_BUILD_RESULT=$RESULT

# trigger post hooks
TRIGGER_POST_DIR=$CONF/$CONFIG-post.d
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
