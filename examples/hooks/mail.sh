#!/bin/sh

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
	fi
fi

# send failure mails
if [ $R -ne 0 ]; then
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
	git --git-dir=$GENCI_REPOSITORY log --format="%ae|%an|%s" $GENCI_BUILD_OLD_SHA1..$GENCI_BUILD_SHA1 | sort | uniq | while read line; do
		email=$(echo $line | cut -d'|' -f1)
		name=$(echo $line | cut -d'|' -f2)
		message=$(echo $line | cut -d'|' -f3-)

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

# cleanup
rm $BODY
