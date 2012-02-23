for head in $(ls $BUILDS); do
	next=$(cat $BUILDS/$head/number)
	current=$(($next - 1))

	# currently running?
	if [ -f $BUILDS/$head/build/$current.sha1 ] && [ ! -f $BUILDS/$head/build/$current.result ]; then
		prev=$(($current - 1))
		prev_sha1=""
		if [ -f $BUILDS/$head/build/$prev.sha1 ]; then
			prev_sha1=$(cat $BUILDS/$head/build/$prev.sha1)
		fi
		echo "running $head $current $(cat $BUILDS/$head/build/$current.sha1) $prev_sha1"

		# for broken check
		current=$(($current - 1))
	fi

	if [ -f $BUILDS/$head/build/$current.result ] && [ -f $HEADS/$head ]; then
		if [ $(cat $BUILDS/$head/build/$current.result) -ne 0 ]; then
			prev=$(($current - 1))
			prev_sha1=""
			if [ -f $BUILDS/$head/build/$prev.sha1 ]; then
				prev_sha1=$(cat $BUILDS/$head/build/$prev.sha1)
			fi
			echo "broken $head $current $(cat $BUILDS/$head/build/$current.sha1) $prev_sha1"
		fi
	fi
done
