for entry in $(ls $CONF); do
	if [ -f $CONF/$entry ]; then
		echo $entry
	fi
done
exit 0
