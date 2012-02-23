for branch in $(ls $HEADS); do
	found=0
	for rbranch in $($GIT for-each-ref --format='%(refname)' refs/heads | cut -d'/' -f3-); do
		if [ "$branch" = "$rbranch" ]; then
			found=1
			break
		fi
	done
	if [ $found -eq 0 ]; then
		echo "delete $branch"
	fi
done

for branch in $(ls $RELEASES); do
	echo "release $branch $(cat $RELEASES/$branch)"
done

for branch in $($GIT for-each-ref --format='%(refname)' refs/heads | cut -d'/' -f3-); do
	if [ ! -f $RELEASES/$branch ]; then
		if [ -f $HEADS/$branch ]; then
			OLD_HEAD=$(cat $HEADS/$branch)
			NEW_HEAD=$($GIT show --pretty=oneline $branch | head -1 | cut -d' ' -f1)
			if [ "$OLD_HEAD" != "$NEW_HEAD" ]; then
				echo "build $branch $NEW_HEAD $OLD_HEAD"
			fi
		else
			NEW_HEAD=$($GIT show --pretty=oneline $branch | head -1 | cut -d' ' -f1)
			echo "build $branch $NEW_HEAD"
		fi
	fi
done
