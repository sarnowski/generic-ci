WEB=$3
if [ -z "$WEB" ] || [ ! -d "$WEB" ] || [ ! -w "$WEB" ]; then
	echo "Usage:  $0 web <configuration> <web-directory>" >&2
	exit 1
fi

filesize() {
	if [ ! -f $1 ]; then
		echo 0
		return
	fi
	if [ ! -z "$(uname | grep -i "BSD")" ]; then
		stat -f "%z" $1
	else
		stat -s $1
	fi
}

running() {
	if [ "$1" = "active" ] || [ "$1" = "inactive" ]; then
		echo
	else
		echo "running"
	fi
}

#
# INDEX
#
cat > $WEB/index.html << "EOF"
<!DOCTYPE html>
<html>
	<head>
EOF

echo "<title>$CONFIG - generic-ci</title>" >> $WEB/index.html

cat >> $WEB/index.html << "EOF"
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<style type="text/css">
			td, th {
				padding: 4px 15px;
				background-color: lightgrey;
				text-align: left;
			}
			a {
				text-decoration: none;
			}
			th a {
				text-weight: bold;
				color: black;
			}
			th.ok {
				background-color: green;
			}
			a.ok {
				color: green;
			}
			th.broken {
				background-color: red;
			}
			a.broken {
				color: red;
			}
			th.running {
				background-color: yellow;
			}
			a.running {
				color: darkyellow;
			}
			th.inactive {
				background-color: grey;
			}
		</style>
	</head>
	<body>
EOF

echo "<h1>$CONFIG build status</h1>" >> $WEB/index.html

echo "<table>" >> $WEB/index.html
$GENCI status $CONFIG | while read line; do
	health=$(echo $line | cut -d' ' -f1)
	branch=$(echo $line | cut -d' ' -f2)
	status=$(echo $line | cut -d' ' -f3)
	last=$(echo $line | cut -d' ' -f4)
	cnt=0

	echo "<tr>" >> $WEB/index.html
	echo "<th class=\"$health $(running $status) $status\"><a href=\"$branch.html\">$branch</a></th>" >> $WEB/index.html
	while [ $(($last - $cnt)) -ge 0 ] && [ $cnt -lt 10 ]; do

		bhealth="broken"
		[ "$(cat $BUILDS/master/build/$(($last - $cnt))/result 2>/dev/null)" = "0" ] && bhealth="ok"

		echo "<td><a class=\"$health\" href=\"$branch-$(($last - $cnt)).txt\">#$(($last - $cnt))</a></td>" >> $WEB/index.html
		cnt=$(($cnt + 1))
	done
	echo "</tr>" >> $WEB/index.html
done

cat >> $WEB/index.html << "EOF"
		</table>
	</body>
</html>
EOF

#
# BRANCHES
#
$GENCI status $CONFIG | while read line; do
	health=$(echo $line | cut -d' ' -f1)
	branch=$(echo $line | cut -d' ' -f2)
	last=$(echo $line | cut -d' ' -f4)

	#
	# BRANCH
	#
	cat > $WEB/$branch.html << "EOF"
<!DOCTYPE html>
<html>
	<head>
EOF

	echo "<title>$CONFIG / $branch - generic-ci</title>" >> $WEB/$branch.html

	cat >> $WEB/$branch.html << "EOF"
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<style type="text/css">
			ul a {
				text-decoration: none;
				font-weight: bold;
			}
			.ok {
				color: green;
			}
			.broken {
				color: red;
			}
		</style>
	</head>
	<body>
EOF

	echo "<h1>$CONFIG / $branch builds history</h1>" >> $WEB/$branch.html
	echo "<a href=\"index.html\">back to overview</a>" >> $WEB/$branch.html

	echo "<ul>" >> $WEB/$branch.html
	build=$last
	while [ $build -ge 0 ]; do
		sha1=$(cat $BUILDS/master/build/$build/sha1)

		bhealth="broken"
		[ "$(cat $BUILDS/master/build/$build/result 2>/dev/null)" = "0" ] && bhealth="ok"

		echo "<li><a href=\"$branch-$build.txt\" class=\"$bhealth\">#$build based on $sha1</a>" >> $WEB/$branch.html

		if [ $build -gt 0 ]; then
			sha1_from=$(cat $BUILDS/master/build/$(($build - 1))/sha1)
			echo "<ul>" >> $WEB/$branch.html
			$GIT log --format="%s (%h) %an, %aD" $sha1_from..$sha1 | while read line; do
				echo "<li>$line</li>" >> $WEB/$branch.html
			done
			echo "</ul>" >> $WEB/$branch.html
		fi

		echo "</li>" >> $WEB/$branch.html

		build=$(($build - 1))
	done
	echo "</ul>" >> $WEB/$branch.html

	cat >> $WEB/$branch.html << "EOF"
	</body>
</html>
EOF


	#
	# BRANCH WIDGET
	#
	cat > $WEB/$branch-widget.html << "EOF"
<!DOCTYPE html>
<html>
	<head>
		<title>generic-ci widget</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<style type="text/css">
			* {
				margin: 0;
				border: 0;
				padding: 0;
			}
			body {
				text-align: center;
			}
			.broken {
				background-color: red;
			}
			.ok {
				background-color: green;
			}
			a {
				font-weight: bold;
				color: black;
				text-decoration: none;
				font-size: 14px;
			}
		</style>
	</head>
EOF

	echo "<body class=\"$health\">" >> $WEB/$branch-widget.html
	echo "<a href=\"$branch-$last.txt\" target=\"_blank\">#$last</a>" >> $WEB/$branch-widget.html


	cat >> $WEB/$branch-widget.html << "EOF"
	</body>
</html>
EOF

	#
	# BRANCH LOGS
	#
	build=$last
	while [ $build -ge 0 ]; do
		orig=$(filesize $BUILDS/$branch/build/$build/log)
		copy=$(filesize $WEB/$branch-$build.txt)

		if [ ! -f $WEB/$branch-$build.txt ] || [ "$orig" != "$copy" ]; then
			cp $BUILDS/$branch/build/$build/log $WEB/$branch-$build.txt
		fi

		build=$(($build - 1))
	done

done
