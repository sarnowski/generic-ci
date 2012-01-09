#!/bin/sh

# only if we broke the build
R=$GITCE_BUILD_RESULT

# prepare mail title
[ $R -eq 0 ] && TITLE="[$GITCE_CONFIG] $GITCE_BUILD_ID -> BUILDS AGAIN"
[ $R -ne 0 ] && TITLE="[$GITCE_CONFIG] $GITCE_BUILD_ID -> FAILED"

# prepare mail body
BODY=/tmp/gitce-mail.$GITCE_BUILD_ID
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

FAILAUTHORS=$GITCE_BRANCH_DIR/failauthors

if [ $R -eq 0 ]; then
	if [ -f $FAILAUTHORS ]; then
		cat $FAILAUTHORS | while read line; do
			email=$(echo $line | cut -d'|' -f1)
			name=$(echo $line | cut -d'|' -f2-)

			echo "Sending E-Mail to $name <$email>..."
			cat $BODY \
				| sed "s/%NAME%/$name/g" \
				| sed "s/%BRANCH%/$GITCE_BRANCH/g" \
				| mail -s "$TITLE" $email
		done
		rm $FAILAUTHORS
	fi
fi

if [ $R -ne 0 ]; then
	# append git and build log
	echo "GIT HISTORY ($GITCE_BUILD_OLD_SHA1..$GITCE_BUILD_SHA1)" >> $BODY
	echo "=============================================================================" >> $BODY
	git --git-dir=$GITCE_REPOSITORY log --oneline $GITCE_BUILD_OLD_SHA1..$GITCE_BUILD_SHA1 >> $BODY
	echo >> $BODY
	echo >> $BODY

	if [ ! -z "$GITCE_BUILD_LOG" ]; then
		echo "BUILD LOG" >> $BODY
		echo "=============================================================================" >> $BODY
		cat $GITCE_BUILD_LOG >> $BODY
		echo >> $BODY
		echo >> $BODY
	fi

	echo "Thank you!" >> $BODY


	# send to authors
	sent=
	git --git-dir=$GITCE_REPOSITORY log --format="%ae|%an|%s" $GITCE_BUILD_OLD_SHA1..$GITCE_BUILD_SHA1 | while read line; do
		email=$(echo $line | cut -d'|' -f1)
		name=$(echo $line | cut -d'|' -f2)
		message=$(echo $line | cut -d'|' -f3-)

		if [ ! -z "$(echo $sent | grep "$email")" ]; then
			continue
		fi

		echo "Sending E-Mail to $name <$email>..."
		cat $BODY \
			| sed "s/%NAME%/$name/g" \
			| sed "s/%BUILD_ID%/$GITCE_BUILD_ID/g" \
			| mail -s "$TITLE" $email
		sent="$sent $email "

		# remember authors for later success message
		if [ ! -f $FAILAUTHORS ] || [ -z "$(grep $email $FAILAUTHORS)" ]; then
			echo "$email|$name" >> $FAILAUTHORS
		fi
	done
fi

# cleanup
rm $BODY
