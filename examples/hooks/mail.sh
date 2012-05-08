#!/bin/sh

if [ "$GENCI_PHASE" != "post" ]; then
	echo "Wrong phase for plugin!" >&2
	exit 1
fi

if [ "$GENCI_BUILD_NUMBER" -eq 0 ]; then
	# ignore the first one, would result in mailing to all persons in history
	# if a newly branched build failes
	echo "Skipping mailing on the first build of a branch."
	exit 0
fi

if [ ! -z "$MAIL_BRANCHES" ]; then
	skip=1
	for white in $MAIL_BRANCHES; do
		if [ "$GENCI_BRANCH" = "$white" ]; then
			skip=0
		fi
	done
	if [ $skip -eq 1 ]; then
		echo "Skipping mailing for the branch (not in mail whitelist)."
		exit 0
	fi
fi

# only if we broke the build
R=$GENCI_BUILD_RESULT

# prepare mail title
[ $R -eq 0 ] && TITLE="[$GENCI_CONFIG] $GENCI_BUILD_ID -> BUILDS AGAIN"
[ $R -ne 0 ] && TITLE="[$GENCI_CONFIG] $GENCI_BUILD_ID -> FAILED"

# prepare mail body
BODY=/tmp/genci-mail.$GENCI_BUILD_ID
[ $R -eq 0 ] && cat > $BODY << "MAIL"
Hello %NAME%,

your branch %BRANCH% builds again!

Congratulations!
MAIL

[ $R -ne 0 ] && cat > $BODY << "MAIL"
Hello %NAME%,

you are involved in build %BUILD_ID% which failed! Please fix this
as soon as possible!


MAIL


FAILAUTHORS=$GENCI_BRANCH_DIR/failauthors

# send recovery mails
if [ $R -eq 0 ]; then
	if [ -f $FAILAUTHORS ]; then
		cat $FAILAUTHORS | while read line; do
			email=$(echo $line | cut -d'|' -f1)
			name=$(echo $line | cut -d'|' -f2-)

			echo "Sending E-Mail to $name <$email>..."
			cat $BODY \
				| sed "s/%NAME%/$name/g" \
				| sed "s/%BRANCH%/$GENCI_BRANCH/g" \
				| mail -s "$TITLE" $email
		done
		rm $FAILAUTHORS
	else
		echo "No mails to send."
	fi
fi

# send failure mails
if [ $R -ne 0 ]; then

	[ -z "$MAIL_PANIC_LIMIT" ] && MAIL_PANIC_LIMIT=0

	# panic mail check
	if [ ! -z "$MAIL_PANIC_MAIL" ]; then
		mail_count=$(git --git-dir=$GENCI_REPOSITORY log --format="%ae|%an" $GENCI_BUILD_OLD_SHA1..$GENCI_BUILD_SHA1 | sort | uniq | wc -l)
	else
		mail_count=0
	fi

	if [ $mail_count -gt $MAIL_PANIC_LIMIT ] && [ $MAIL_PANIC_LIMIT -ne 0 ]; then
		# PANIC!
		echo "Too many authors ($mail_count)! Sending one mail to $MAIL_PANIC_MAIL..."
		echo "$GENCI_BUILD_ID failed and there were too many authors involved to send them mails!" \
			| mail -s "[$GENCI_CONFIG] $GENCI_BUILD_ID failed with too many authors" $MAIL_PANIC_MAIL

	else

		# append git and build log
		echo "GIT HISTORY ($GENCI_BUILD_OLD_SHA1..$GENCI_BUILD_SHA1)" >> $BODY
		echo "=============================================================================" >> $BODY
		git --git-dir=$GENCI_REPOSITORY log --oneline $GENCI_BUILD_OLD_SHA1..$GENCI_BUILD_SHA1 >> $BODY
		echo >> $BODY
		echo >> $BODY

		if [ ! -z "$GENCI_BUILD_LOG" ]; then
			echo "BUILD LOG" >> $BODY
			echo "=============================================================================" >> $BODY
			cat $GENCI_BUILD_LOG >> $BODY
			echo >> $BODY
			echo >> $BODY
		fi

		echo "Thank you!" >> $BODY

		# send to authors
		git --git-dir=$GENCI_REPOSITORY log --format="%ae|%an" $GENCI_BUILD_OLD_SHA1..$GENCI_BUILD_SHA1 | sort | uniq | while read line; do
			email=$(echo $line | cut -d'|' -f1)
			name=$(echo $line | cut -d'|' -f2)

			echo "Sending E-Mail to $name <$email>..."
			cat $BODY \
				| sed "s/%NAME%/$name/g" \
				| sed "s/%BUILD_ID%/$GENCI_BUILD_ID/g" \
				| mail -s "$TITLE" $email

			# remember authors for later success message
			if [ ! -f $FAILAUTHORS ] || [ -z "$(grep $email $FAILAUTHORS)" ]; then
				echo "$email|$name" >> $FAILAUTHORS
			fi
		done
	fi
fi

# cleanup
rm $BODY
