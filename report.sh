#!/bin/sh
cd $(dirname $0)

# clean up old logs first
rm -f test-*.log
if [ $(ls test-*.log 2>/dev/null | wc -l) -ne 0 ]; then
	echo "Cannot clean all log files; please clean them manually:" >&2
	ls test-*.log >&2
	exit 1
fi

# basic system informations
echo "============ system ==========================================="
echo System: $(uname -a)
echo Hostname: $(hostname)
echo Bin: $0
echo Pwd: $(pwd)
echo Shell: $SHELL
echo User: $USER
echo Version: $(git describe --tags 2>&1)
echo Date: $(date)
echo

# run the tests
echo "============ test suite ======================================="
./test.sh 2>&1

if [ $(ls test-*.log 2>/dev/null | wc -l) -ne 0 ]; then
	# some tests failed!
	for log in $(ls test-*.log); do
		echo
		echo "============ $log =============================="
		cat $log
	done
fi

echo
echo "============ git status ======================================="
git status 2>&1

echo
echo "============ environment ======================================"
env
