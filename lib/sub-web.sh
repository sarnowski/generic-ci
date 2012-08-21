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
		stat -c "%s" $1
	fi
}

modifiedtime() {
	if [ ! -e $1 ]; then
		echo 0
		return
	fi
	if [ ! -z "$(uname | grep -i "BSD")" ]; then
		stat -f "%m" $1
	else
		stat -c "%Y" $1
	fi
}

running() {
	if [ "$1" = "active" ] || [ "$1" = "inactive" ]; then
		echo
	else
		echo "running"
	fi
}

html() {
	sed 's/</&lt;/g' \
		| sed 's/>/&gt;/g'
}

css() {
	sed 's/"/\\"/g' \
		sed "s/'/\\\\'/g"
}

#
# PREPARATION
# copy all logs+artifacts
#
$GENCI status $CONFIG | while read line; do
	health=$(echo $line | cut -d' ' -f1)
	branch=$(echo $line | cut -d' ' -f2)
	last=$(echo $line | cut -d' ' -f4)

	build=$last
	while [ $build -ge 0 ]; do
		if [ ! -f $BUILDS/$branch/build/$build/log ]; then
			build=$(($build - 1))
			continue
		fi
		orig=$(filesize $BUILDS/$branch/build/$build/log)
		copy=$(filesize $WEB/$branch-$build.txt)

		if [ ! -f $WEB/$branch-$build.txt ] || [ "$orig" != "$copy" ]; then
			cp $BUILDS/$branch/build/$build/log $WEB/$branch-$build.txt
		fi

		if [ -d $BUILDS/$branch/build/$build/artifacts ]; then
			orig=$(modifiedtime $BUILDS/$branch/build/$build/artifacts)
			copy=$(modifiedtime $WEB/$branch-$build)

			if [ ! -d $WEB/$branch-$build ] || [ "$orig" != "$copy" ]; then
				rm -rf $WEB/$branch-$build
				cp -a $BUILDS/$branch/build/$build/artifacts $WEB/$branch-$build
			fi
		fi

		build=$(($build - 1))
	done

done

#
# CSS
#
cat > $WEB/genci.css << "EOF"
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed, 
figure, figcaption, footer, header, hgroup, 
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	font-family: Arial, sans-serif;
	vertical-align: baseline;
}
article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section {
	display: block;
}
body {
	line-height: 1;
}
ol, ul {
	list-style: none;
}
blockquote, q {
	quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
	content: '';
	content: none;
}
table {
	border-collapse: collapse;
	border-spacing: 0;
}


body {
	padding: 20px 10px;
	background-color: white;
}
h1 {
	font-size: 32px;
	font-weight: bold;
	margin-bottom: 20px;
}
h2 {
	margin-bottom: 30px;
}
td, th {
	padding: 4px 15px;
	background-color: lightgrey;
	text-align: left;
	border: 1px solid white;
}
a {
	text-decoration: none;
}
a:hover {
	text-decoration: underline;
}
th a {
	font-weight: bold;
	color: black;
}
.ok {
	color: black;
}
.broken {
	color: red;
}
.running {
	color: yellow;
}
th.ok {
	color: black;
	background-color: #0d0;
}
th.broken {
	color: black;
	background-color: red;
}
th.running {
	color: black;
	background-color: yellow;
}
th.inactive {
	color: black;
	background-color: grey;
}
p {
	margin-top: 20px;
	font-size: 10px;
}
ul a {
	text-decoration: none;
	font-weight: bold;
}
li > ul {
	margin: 0 0 10px 70px;
}

li > ul li {
	list-style-type: disc;
	margin: 5px 0;
}
EOF

#
# INDEX
#
cat > $WEB/index.html << "EOF"
<!DOCTYPE html>
<html>
	<head>
EOF

echo "<title>$CONFIG build status</title>" >> $WEB/index.html

cat >> $WEB/index.html << "EOF"
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="generator" content="generic-ci" />
		<link rel="stylesheet" type="text/css" href="genci.css" />
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
		build=$((last - $cnt))

		if [ ! -f $BUILDS/$branch/build/$build/sha1 ]; then
			cnt=$(($cnt + 1))
			continue
		fi

		bhealth="running"
		if [ -f $BUILDS/$branch/build/$build/result ]; then
			bhealth="broken"
			[ "$(cat $BUILDS/$branch/build/$build/result)" = "0" ] && bhealth="ok"
		fi

		artifacts_link=
		if [ -d $WEB/$branch-$build ]; then
			artifacts_link="<a href="$branch-$build/">*</a>"
		fi

		echo "<td><a class=\"$bhealth\" href=\"$branch-$build.txt\">#$build</a>$artifacts_link</td>" >> $WEB/index.html
		cnt=$(($cnt + 1))
	done
	echo "</tr>" >> $WEB/index.html
done

echo "</table>
        <p>Builds powered by <a href=\"http://trustedco.de/generic-ci/\" target=\"_blank\">generic-ci</a>, $(date)</p>
	</body>
</html>" >> $WEB/index.html


#
# MONITOR
#
status="ok"
if [ ! -z "$($GENCI status $CONFIG | grep "broken" | grep -v "inactive")" ]; then
	status="broken"
fi
cat > $WEB/monitor.html << "EOF"
<!DOCTYPE html>
<html>
	<head>
		<title>generic-ci monitor</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta http-equiv="refresh" content="5"/>
		<meta name="generator" content="generic-ci" />
		<style type="text/css">
			* {
				margin: 0;
				border: 0;
				padding: 0;
			}
			.ok {
				background-color: #0d0;
			}
			.broken {
				background-color: red;
			}
			body {
				width: 100%;
			}
			h1 {
				color: black;
				font-size: 72px;
				font-weight: bold;
				font-family: Arial, sans-serif;
				margin-top: 100px;
				text-align: center;
			}
		</style>
	</head>
EOF

echo "<body class=\"$status\">" >> $WEB/monitor.html
echo "<h1>$CONFIG</h1>" >> $WEB/monitor.html

cat >> $WEB/monitor.html << "EOF"
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

	echo "<title>$CONFIG / $branch builds history</title>" >> $WEB/$branch.html

	cat >> $WEB/$branch.html << "EOF"
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="generator" content="generic-ci" />
		<link rel="stylesheet" type="text/css" href="genci.css" />
	</head>
	<body>
EOF

	echo "<h1>$CONFIG / $branch builds history</h1>" >> $WEB/$branch.html
	echo "<h2><a href=\"index.html\">back to overview</a></h2>" >> $WEB/$branch.html

	echo "<ul>" >> $WEB/$branch.html
	build=$last
	while [ $build -ge 0 ]; do
		if [ ! -f $BUILDS/$branch/build/$build/sha1 ]; then
			build=$(($build - 1))
			continue
		fi

		sha1=$(cat $BUILDS/$branch/build/$build/sha1)

		bhealth="running"
		if [ -f $BUILDS/$branch/build/$build/result ]; then
			bhealth="broken"
			[ "$(cat $BUILDS/$branch/build/$build/result)" = "0" ] && bhealth="ok"
		fi

		artifacts_link=
		if [ -d $WEB/$branch-$build ]; then
			artifacts_link=" [<a href="$branch-$build/">artifacts</a>]"
		fi

		based=$($GIT describe --tags $sha1 2>/dev/null)
		if [ -z "$based" ]; then
			based="$sha1"
		else
			based="$based"
		fi

		echo "<li><a href=\"$branch-$build.txt\" class=\"$bhealth\">#$build [$bhealth] based on $based</a>$artifacts_link" >> $WEB/$branch.html

		if [ $build -gt 0 ]; then
			sha1_from=$(cat $BUILDS/$branch/build/$(($build - 1))/sha1)
			echo "<ul>" >> $WEB/$branch.html
			$GIT log --format="%s (%h) %an, %aD" $sha1_from..$sha1 | while read line; do
				echo "<li>$(echo $line | html)</li>" >> $WEB/$branch.html
			done
			echo "</ul>" >> $WEB/$branch.html
		fi

		echo "</li>" >> $WEB/$branch.html

		build=$(($build - 1))
	done
	echo "</ul>" >> $WEB/$branch.html

    echo "
        <p>Builds powered by <a href=\"http://trustedco.de/generic-ci/\" target=\"_blank\">generic-ci</a>, $(date)</p>
	</body>
</html>" >> $WEB/$branch.html


	#
	# BRANCH WIDGET
	#
	cat > $WEB/$branch-widget.html << "EOF"
<!DOCTYPE html>
<html>
	<head>
		<title>generic-ci widget</title>
		<meta http-equiv="refresh" content="23"/>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="generator" content="generic-ci" />
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
				background-color: #0d0;
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

done
