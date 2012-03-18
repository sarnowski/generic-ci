#!/bin/sh

cd $(dirname $0)
h=$(pwd)

# in case..
mkdir -p $HOME/.genci/works

# set up environment
export GENCI_HOME=$h
export GENCI=$h/genci

failed=0
success=0
for t in $(ls tests); do
	# prepare
	config=$(date +%s)-$t
	echo "SOURCE=/tmp/$config" > $HOME/.genci/$config

	# prepare a fake git repository
	mkdir /tmp/$config
	cd /tmp/$config
	cat > test.sh << "EOF"
#!/bin/sh
exit 0
EOF
	chmod +x test.sh
	cat > release.sh << "EOF"
#!/bin/sh
exit 0
EOF
	chmod +x release.sh
	git init >/dev/null
	git add . >/dev/null
	git commit -m "initial commit" >/dev/null

	# execute the test
	cd $h
	tests/$t $config /tmp/$config >test-$t.log 2>&1
	result=$?

	if [ $result -eq 0 ]; then
		echo "OK    $t"
		rm test-$t.log
		success=$(($success + 1))
	else
		echo "Return Code: $result" >> test-$t.log
		echo "FAIL  $t  (output: test-$t.log)"
		failed=$(($failed + 1))
	fi

	# cleanup
	rm $HOME/.genci/$config
	rm -rf $HOME/.genci/works/$config
	rm -rf /tmp/$config
done

if [ $failed -eq 0 ]; then
	echo "All $success tests passed." >&2
else
	echo "$failed tests failed out of $(($failed + $success)) tests!" >&2
fi
exit $failed
