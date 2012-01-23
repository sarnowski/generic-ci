if [ -z "$3" ]; then
	panic "Usage:  $0 run-newest $2 <branch>"
fi

$0 update $2 || exit $?
$0 run $2 $3 || exit $?
