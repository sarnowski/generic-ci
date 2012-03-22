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

# lock the config
require_locked_config

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
export GENCI_CONF=$CONF
export GENCI_CONFIG=$CONFIG
export GENCI_REPOSITORY=$REPOSITORY
export GENCI_BRANCH=$BRANCH
export GENCI_BRANCH_DIR=$BRANCH_DIR
export GENCI_BUILD_ID=$BUILD_ID
export GENCI_BUILD_NUMBER=$BUILD_NUMBER
export GENCI_BUILD_SHA1=$SHA1
export GENCI_BUILD_DIR=$BUILD_DIR
export GENCI_BUILD_WORK_DIR=$BUILD_WORK_DIR
export GENCI_BUILD_USER=$BUILD_USER
export GENCI_BUILD_COMMAND=$BUILD_COMMAND
export GENCI_PHASE="init"

if [ $BUILD_NUMBER -gt 0 ]; then
	last_build=$(($BUILD_NUMBER - 1))
	if [ -f $BRANCH_DIR/build/$last_build/sha1 ]; then
		export GENCI_BUILD_OLD_SHA1=$(cat $BRANCH_DIR/build/$last_build/sha1)
	fi
fi

# set up some variables, su does not set up for us
if [ $(id -u) -eq 0 ] && [ ! -z "$BUILD_USER" ]; then
	export HOME=$(grep "^$BUILD_USER:" /etc/passwd | cut -d':' -f6)
	export USER=$BUILD_USER
	export LOGNAME=$BUILD_USER
	echo "Resetting environment for $USER to home $HOME"
fi

# trigger pre hooks
export GENCI_PHASE="pre"
for hook in $PRE; do
	$hook
	hook_result=$?

	if [ $hook_result -ne 0 ]; then
		echo $hook_result > $BUILD_RESULT
		echo $SHA1 > $HEADS/$BRANCH
		echo "Aborting build due to failure during pre-hooks!"
		exit $hook_result
	fi
done

# run the command
export GENCI_PHASE="run"

echo "Build Informations:"
echo "  System: $(uname -a)"
echo "  Hostname: $(hostname)"
echo "  Version: $($GENCI version)"
echo "  Environment:"
env | sort | while read line; do
	echo "   $line"
done

cd $BUILD_WORK_DIR

if [ $(id -u) -eq 0 ]; then
	if [ ! -z "$BUILD_USER" ] && [ -z "$CHROOT_SETUP" ]; then
		chown -R $BUILD_USER $BUILD_WORK_DIR

		if [ "$(uname)" = "OpenBSD" ]; then
			COMMAND="su $BUILD_USER -c \"$COMMAND\""
		else
			COMMAND="su -p -c \"$COMMAND\" $BUILD_USER"
		fi
	elif [ ! -z "$CHROOT_SETUP" ]; then
		mkdir -p $BUILD_DIR/newroot
		$CHROOT_SETUP $BUILD_DIR/newroot
		chroot_result=$?

		if [ $chroot_result -ne 0 ]; then
			echo $chroot_result > $BUILD_RESULT
			echo $SHA1 > $HEADS/$BRANCH
			echo "Aborting build due to failure during chroot setup!"
			exit $chroot_result
		fi

		mv $BUILD_WORK_DIR $BUILD_DIR/newroot/checkout
		mv $BUILD_DIR/newroot $BUILD_WORK_DIR

		echo "Preparing chrooted command:  $COMMAND"
		cat > $BUILD_WORK_DIR/run.sh << "EOF"
#!/bin/sh
cd /checkout
EOF
		echo $COMMAND >> $BUILD_WORK_DIR/run.sh
		chmod +x $BUILD_WORK_DIR/run.sh

		if [ -z "$BUILD_USER" ]; then
			COMMAND="chroot $BUILD_WORK_DIR /run.sh"
		else
			chown -R $BUILD_USER $BUILD_WORK_DIR/checkout

			export LD_LIBRARY_PATH="/usr/local/lib"
			if [ "$(uname)" = "OpenBSD" ]; then
				COMMAND="chroot -u $BUILD_USER $BUILD_WORK_DIR /run.sh"
			else
				COMMAND="chroot -userspec=$BUILD_USER $BUILD_WORK_DIR /run.sh"
			fi
		fi
	fi
fi

echo "Running build command:  $COMMAND"
$COMMAND
RESULT=$?

# the result
echo $RESULT > $BUILD_RESULT
echo $SHA1 > $HEADS/$BRANCH
echo "Return code: $RESULT"
export GENCI_BUILD_RESULT=$RESULT

# trigger post hooks
export GENCI_PHASE="post"
for hook in $POST; do
	$hook
done

# for logging
date

# unlock config
unlock_config

# end the run
if [ $RESULT -eq 0 ]; then
	echo "$BUILD_ID successful"
	exit 0
else
	echo "$BUILD_ID failed"
	exit $RESULT
fi
