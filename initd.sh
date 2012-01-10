#!/bin/sh

### BEGIN INIT INFO
# Provides:		gitce-watchers
# Required-Start:	$local_fs
# Required-Stop:	$local_fs
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
### END INIT INFO

case $1 in
	start)
		if [ -d /etc/gitce ]; then
			echo -n "Starting gitce watchers..."
			for config in $(ls /etc/gitce); do
				[ ! -f /etc/gitce/$config ] && continue
				[ ! -z "$(echo $config | grep "nowatch")" ] && continue
				if [ ! -f /etc/gitce/$config.nowatch ]; then
					echo -n " $config"
					mkdir -p /var/log/gitce/$(dirname $config)
					nohup gitce watch $config >> /var/log/gitce/$config.log 2>&1 &
				fi
			done
			echo
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
