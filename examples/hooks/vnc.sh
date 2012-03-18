#!/bin/sh

# it is nessecary to configure the DISPLAY variable
# add something like this to your configuration
#  export DISPLAY=:10

# you have to configure the vnc server before running
# the plugin.
#  1. set a password for your vnc server
#  2. cleanup your xstartup file
#  3. you may need to allow your host, easiest way is
#     to add "xhost +" to your xstartup file

if [ -z "$DISPLAY" ]; then
	exit 0
fi

# test for vncserver
which vncserver >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "vncserver not found in PATH" >&2
	exit 1
fi

if [ "$GENCI_PHASE" = "pre" ]; then
	# start him
	if [ $(id -u) -eq 0 ] && [ ! -z "$GENCI_BUILD_USER" ]; then
		echo "Starting VNC server on display $DISPLAY for $GENCI_BUILD_USER..."
		su -c "vncserver $DISPLAY" $GENCI_BUILD_USER &
	else
		echo "Starting VNC server on display $DISPLAY..."
		vncserver $DISPLAY &
	fi
	sleep 5  # give him a chance to start
else
	# kill him
	if [ $(id -u) -eq 0 ] && [ ! -z "$GENCI_BUILD_USER" ]; then
		echo "Killing VNC server on display $DISPLAY of $GENCI_BUILD_USER..."
		su -c "vncserver -kill $DISPLAY" $GENCI_BUILD_USER
	else
		echo "Killing VNC server on display $DISPLAY..."
		vncserver -kill $DISPLAY
	fi
fi
