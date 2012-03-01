#!/bin/sh

cd $(dirname $0)
h=$(pwd)

# in case..
mkdir -p $HOME/.gitce/works

# set up environment
export GITCE_HOME=$h
export GITCE=$h/gitce

failed=0
for t in $(ls tests); do
	# prepare
	config=$(date +%s)-$t
	echo "SOURCE=/tmp/$config" > $HOME/.gitce/$config

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
	tests/$t $config /tmp/$config >test-$t 2>&1
	result=$?

	if [ $result -eq 0 ]; then
		echo "OK    $t"
		rm test-$t
	else
		echo "FAIL  $t  (output: test-$t)"
		echo "Return Code: $result" >> test-$t
		failed=$(($failed + 1))
	fi

	# cleanup
	rm $HOME/.gitce/$config
	rm -rf $HOME/.gitce/works/$config
	rm -rf /tmp/$config
done

if [ $failed -eq 0 ]; then
	echo "All tests passed." >&2
else
	echo "$failed tests failed!" >&2
fi
exit $failed
