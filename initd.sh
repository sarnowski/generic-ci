#!/bin/sh

case $1 in
	start)
		if [ -d /etc/gitce ]; then
			echo -n "Starting gitce watchers..."
			for config in $(ls /etc/gitce); do
				[ ! -f /etc/gitce/$config ] && continue
				echo -n " $config"
				nohup gitce watch $config > /var/log/gitce.log 2>&1 &
			done
			echo
		fi
		;;
	stop)
		echo "Stopping all gitce watchers..."
		killall gitce
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
