while [ true ]; do
	# update repository
	$0 update $2
	LAST_CHECK=$(date +%M)

	# clean up old branches
	for branch in $($0 status $2 | grep "deleted" | cut -d' ' -f2); do
		rm $HEADS/$branch
		rm -f $RELEASES/$branch
		echo "Branch $branch deleted."
	done

	# look for things to build
	first=
	master=0
	build=
	for branch in $($0 status $2 | cut -d' ' -f2); do
		if [ -z "$first" ]; then
			first=$branch
		fi
		if [ "$branch" = "master" ]; then
			master=1
		fi
	done
	if [ $master -eq 1 ]; then
		build=master
	elif [ ! -z "$first" ]; then
		build=$first
	fi

	if [ ! -z "$build" ]; then
		# set up basics
		BRANCH_DIR=$BUILDS/$build
		mkdir -p $BRANCH_DIR

		# get the build number
		BUILD_NUMBER_FILE=$BRANCH_DIR/number
		if [ ! -f $BUILD_NUMBER_FILE ]; then
			BUILD_NUMBER=0
		else
			BUILD_NUMBER=$(cat $BUILD_NUMBER_FILE)
		fi
		BUILD_ID=$build-$BUILD_NUMBER
		BUILD_DIR=$BRANCH_DIR/build/$BUILD_NUMBER
		BUILD_LOG=$BUILD_DIR.log

		# trigger variables
		export GITCE_BUILD_LOG=$BUILD_LOG
		export GITCE_BUILD_OLD_SHA1=$($0 status $2 | grep "$build " | cut -d' ' -f4)

		mkdir -p $(dirname $BUILD_LOG)
		if [ -f $RELEASES/$branch ]; then
			echo "Releasing $BUILD_ID..."
			REF=$(cat $RELEASES/$branch)
			nohup $0 release $2 $branch $REF 2>&1 | tee $BUILD_LOG
			rm $RELEASES/$branch
		elif [ "$AUTO_RUN" != "no" ]; then
			echo "Testing $BUILD_ID..."
			nohup $0 run $2 $branch 2>&1 | tee $BUILD_LOG
		fi
	else
		# done, wait a short time period
		while [ $(date +%M) -eq $LAST_CHECK ]; do
			sleep 1
		done
	fi
done
