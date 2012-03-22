echo "==== generic-ci configuration setup ===="
echo

INPUT_CONFIG=
while [ true ]; do
	echo "Configuration Name:"
	echo "  This has to be a unique name which will identify your configuration."
	read INPUT_CONFIG
	if [ ! -z "$INPUT_CONFIG" ] && [ ! -f $CONF/$INPUT_CONFIG ]; then
		break
	fi
	echo "A configuration name is required which does not already exist!"
done
echo

INPUT_SOURCE=
while [ true ]; do
	echo "Source:"
	echo "  The source has to be a git repository url."
	read INPUT_SOURCE
	[ ! -z "$INPUT_SOURCE" ] && break
	echo "You have to enter a source for the configuration!"
done
echo

INPUT_RUN_TESTS=
echo "Should the configuration run tests automatically? [yes]"
echo "  generic-ci will check your repository periodically and will trigger"
echo "  test builds."
read INPUT_RUN_TESTS
[ -z "$INPUT_RUN_TESTS" ] && INPUT_RUN_TESTS="yes"
echo

INPUT_TEST_COMMAND=
if [ -z "$INPUT_RUN_TESTS" ] || [ "$INPUT_RUN_TESTS" = "yes" ]; then
	echo "Test Command: [./test.sh]"
	echo "  The test command has to return if the build is ok or broken."
	read INPUT_TEST_COMMAND
	[ -z "$INPUT_TEST_COMMAND" ] && INPUT_TEST_COMMAND="./test.sh"
	echo
fi

INPUT_RELEASE_COMMAND=
echo "Release Command (ignore if you don't use it): [./release.sh]"
echo "  The release command has to return if the build was ok or failed."
read INPUT_RELEASE_COMMAND
[ -z "$INPUT_RELEASE_COMMAND" ] && INPUT_RELEASE_COMMAND="./release.sh"
echo

if [ $(id -u) -eq 0 ]; then
	echo "Build User (leave blank if root shall be used):"
	echo "  Running a build as a non-privileged user is recommended as"
	echo "  it prevents your system to be affected by broken build"
	echo "  scripts or tests."
	read INPUT_BUILD_USER
	echo
fi


echo
echo "==== Summary ===="
echo
echo "Configuration Name:  $INPUT_CONFIG"
echo "Source:              $INPUT_SOURCE"
echo "Run Tests:           $INPUT_RUN_TESTS"
echo "Test Command:        $INPUT_TEST_COMMAND"
echo "Release Command:     $INPUT_RELEASE_COMMAND"
echo "Build User:          $INPUT_BUILD_USER"
echo
echo "Are those settings correct? (yes/no)"
read CONFIRM
if [ "$CONFIRM" != "yes" ]; then
	exit 1
fi
echo

echo
echo "==== Setting up the configuration... ===="
echo
mkdir -p $CONF
config_file=$CONF/$INPUT_CONFIG

cat $EXAMPLES/example-config \
	| sed "s§^#RUN_TESTS=.*$§RUN_TESTS=\"$INPUT_RUN_TESTS\"§" \
	| sed "s§^#TEST_COMMAND=.*$§TEST_COMMAND=\"$INPUT_TEST_COMMAND\"§" \
	| sed "s§^#RELEASE_COMMAND=.*$§RELEASE_COMMAND=\"$INPUT_RELEASE_COMMAND\"§" \
	| sed "s§^#BUILD_USER=.*$§BUILD_USER=\"$INPUT_BUILD_USER\"§" \
	> $config_file

$GENCI init $INPUT_CONFIG $INPUT_SOURCE
result=$?
echo

if [ $result -eq 0 ]; then
	echo "Configuration $INPUT_CONFIG successfully created. Edit $config_file for"
	echo "more configuration options (like hooks)."
	echo
	echo "To enable the configuration, add the following line to 'crontab -e':"
	echo "*  *  *  *  *  $0 watch $INPUT_CONFIG"
	echo
	exit 0
else
	rm $config_file
	echo "Configuration $INPUT_CONFIG yould not be created. Check the above error"
	echo "messages for more details."
	exit 1
fi
