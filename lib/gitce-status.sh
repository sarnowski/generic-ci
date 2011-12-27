for branch in $($GIT for-each-ref --format='%(refname)' | cut -d'/' -f3-); do
	if [ -f $HEADS/$branch ]; then
		OLD_HEAD=$(cat $HEADS/$branch)
		NEW_HEAD=$($GIT show --pretty=oneline $branch | head -1 | cut -d' ' -f1)
		if [ "$OLD_HEAD" != "$NEW_HEAD" ]; then
			echo "changed $branch $NEW_HEAD $OLD_HEAD"
		fi
	else
		NEW_HEAD=$($GIT show --pretty=oneline $branch | head -1 | cut -d' ' -f1)
		echo "created $branch $NEW_HEAD"
	fi
done

for branch in $(ls $HEADS); do
	found=0
	for rbranch in $($GIT for-each-ref --format='%(refname)' | cut -d'/' -f3-); do
		if [ "$branch" = "$rbranch" ]; then
			found=1
			break
		fi
	done
	if [ $found -eq 0 ]; then
		echo "deleted $branch"
	fi
done
