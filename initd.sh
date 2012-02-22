#!/bin/sh

### BEGIN INIT INFO
# Provides:		gitce-watchers
# Required-Start:	$local_fs
# Required-Stop:	$local_fs
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
### END INIT INFO

if [ $(id -u) -eq 0 ]; then
	CONFIG_DIR=/etc/gitce
	LOG_DIR=/var/log/gitce
else
	CONFIG_DIR=$HOME/.gitce
	LOG_DIR=$CONFIG_DIR/logs
fi

case $1 in
	start)
		if [ -d $CONFIG_DIR ]; then
			echo "Starting gitce watchers..."
			for config in $(ls $CONFIG_DIR); do
				[ ! -f $CONFIG_DIR/$config ] && continue

				echo "    * $config"
				mkdir -p $LOG_DIR/$(dirname $config)
				nohup /usr/local/bin/gitce watch $config >> $LOG_DIR/$config.log 2>&1 &
			done
			exit 0
		fi
		;;
	stop)
		echo "Stopping all gitce watchers..."
		killall gitce
		exit 0
		;;
	restart)
		$0 stop
		$0 start
		;;
	*)
		echo "Usage: $0 <start|stop|restart>" >&2
		exit 1
		;;
esac
