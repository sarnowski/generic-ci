used_branches=

printed() {
	for branch in $used_branches; do
		if [ "$branch" = "$1" ]; then
			echo "1"
			return
		fi
	done
	echo "0"
}

last_result() {
	if [ ! -f $BUILDS/$branch/number ]; then
		echo "0"
		return
	fi

	next_number=$(cat $BUILDS/$branch/number)
	current_number=$(($next_number - 1))
	last_number=$(($current_number - 1))

	if [ -f $BUILDS/$branch/build/$current_number/result ]; then
		cat $BUILDS/$branch/build/$current_number/result
	elif [ -f $BUILDS/$branch/build/$last_number/result ]; then
		cat $BUILDS/$branch/build/$last_number/result
	else
		echo "0"
	fi
}

running() {
	branch=$1

	if [ ! -f $BUILDS/$branch/number ]; then
		echo "0"
		return
	fi

	next_number=$(cat $BUILDS/$branch/number)
	current_number=$(($next_number - 1))

	if [ -f $BUILDS/$branch/build/$current_number/pid ] && [ ! -f $BUILDS/$branch/build/$current_number/result ]; then
		if [ $(ps $(cat $BUILDS/$branch/build/$current_number/pid) | wc -l) -eq 2 ]; then
			echo "1"
		else
			echo "0"
		fi
	else
		echo "0"
	fi
}

number() {
	branch=$1

	if [ -f $BUILDS/$branch/number ]; then
		number=$(($(cat $BUILDS/$branch/number) - 1))
	else
		number=0
	fi

	echo $number
}

print_branch() {
	if [ $(printed $branch) -ne 0 ]; then
		return
	fi

	branch=$1
	action=$2

	number=$(number $branch)

	if [ $(running $branch) -eq 1 ]; then
		running="running"
	else
		running=""
	fi

	if [ $(last_result $branch) -eq 0 ]; then
		status="ok"
	else
		status="broken"
	fi

	echo "$status $branch $action $number $running"

	used_branches="$used_branches $branch"
}

branches=$($GENCI pending $CONFIG | while read line; do
	action=$(echo $line | cut -d' ' -f1)
	branch=$(echo $line | cut -d' ' -f2)

	if [ "$action" != "delete" ]; then
		echo "$branch|$action"
	fi
done)
for branch in $branches; do
	action=$(echo $branch | cut -d'|' -f2)
	branch=$(echo $branch | cut -d'|' -f1)

	print_branch $branch $action
done

for branch in $(ls $HEADS); do
	print_branch $branch "active"
done

for branch in $(ls $BUILDS); do
	print_branch $branch "inactive"
done
