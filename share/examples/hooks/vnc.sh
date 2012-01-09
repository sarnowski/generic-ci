#!/bin/sh
if [ -z "$DISPLAY" ]; then
	exit 0
fi

# test for vncserver
which vncserver >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "vncserver not found in PATH" >&2
	exit 1
fi

if [ "$GITCE_PHASE" = "pre" ]; then
	# start him
	if [ $(id -u) -eq 0 ] && [ ! -z "$GITCE_BUILD_USER" ]; then
		echo "Starting VNC server on display $DISPLAY for $GITCE_BUILD_USER..."
		su -c "vncserver $DISPLAY" $GITCE_BUILD_USER &
	else
		echo "Starting VNC server on display $DISPLAY..."
		vncserver $DISPLAY &
	fi
	sleep 5  # give him a chance to start
else
	# kill him
	if [ $(id -u) -eq 0 ] && [ ! -z "$GITCE_BUILD_USER" ]; then
		echo "Killing VNC server on display $DISPLAY of $GITCE_BUILD_USER..."
		su -c "vncserver -kill $DISPLAY" $GITCE_BUILD_USER
	else
		echo "Killing VNC server on display $DISPLAY..."
		vncserver -kill $DISPLAY
	fi
fi
