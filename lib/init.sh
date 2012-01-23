panic() {
	echo $*
	exit 1
}

# set up basic variables
CONFIG=$2

if [ $(id -u) -eq 0 ] || [ -z "$HOME" ]; then
	# running as root
	CONFIG_DIR=/etc/gitce
	WORKS_DIR=/var/lib/gitce
else
	# running as unprivileged user
	CONFIG_DIR=$HOME/.gitce
	WORKS_DIR=$HOME/.gitce/works
fi
mkdir -p $CONFIG_DIR || exit $?

# load the configuration
if [ -f $CONFIG ]; then
	CONFIG_DIR=$(dirname $CONFIG)
	CONFIG=$(basename $CONFIG)
fi
if [ -f $CONFIG_DIR/$CONFIG ]; then
	. $CONFIG_DIR/$CONFIG
else
	panic "Configuration $CONFIG_DIR/$CONFIG not found!"
fi

# sanitize configuration
if [ -z "$REPOSITORY" ]; then
	panic "REPOSITORY not set in $CONFIG_DIR/$CONFIG!"
fi

# set up defaults
[ -z "$WORK_DIR" ] && WORK_DIR=$WORKS_DIR/$CONFIG
[ -z "$GIT_BIN" ] && GIT_BIN=git

# set up internal defaults
REPO=$WORK_DIR/repository
BUILDS=$WORK_DIR/builds
HEADS=$WORK_DIR/heads

# check for repository
if [ ! -d $REPO ]; then
	# clone it
	mkdir -p $(dirname $REPO) || exit $?
	$GIT_BIN clone --mirror $REPOSITORY $REPO || exit $?
fi
GIT="$GIT_BIN --git-dir=$REPO"

# create directories
mkdir -p $BUILDS
mkdir -p $HEADS
