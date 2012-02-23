while [ true ]; do
	# update repository
	$GITCE update $CONFIG
	last_check=$(date +%M)

	# parse status
	build=
	release=
	todo=$($GITCE pending $CONFIG | while read status; do
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

	# look for things to build
	if [ -z "$action" ]; then
		# done, wait a short time period
		while [ $(date +%M) -eq $last_check ]; do
			sleep 1
		done
		continue
	fi

	# check if we do normal builds
	if [ "$AUTO_RUN" = "no" ] && [ "$action" != "release" ]; then
		continue
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
	export GITCE_BUILD_LOG=$BUILD_LOG

	# prepare build directory
	mkdir -p $BUILD_DIR

	if [ "$action" = "release" ]; then
		echo "Releasing $BUILD_ID..."
		release_ref=$(cat $RELEASES/$branch)

		nohup $GITCE run $CONFIG --release $branch $release_ref 2>&1 | tee $BUILD_LOG

		rm $RELEASES/$release

	elif [ "$action" = "build" ]; then
		echo "Testing $BUILD_ID..."
		nohup $GITCE run $CONFIG $branch 2>&1 | tee $BUILD_LOG
	fi
done
