#!/bin/sh

### BEGIN INIT INFO
# Provides:          set-hostname
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     5
# Default-Stop:      0 1 2 3 4 6
# Short-Description: Set hostname from file
# Description:       Set hostname from configuration file /etc/hostname
### END INIT INFO

# Before installing, this script was stored as file: /etc/init.d/set-hostname
#
# About the LSB comment header and more: https://wiki.debian.org/LSBInitScripts/
#
# Install the init script links with: `sudo /sbin/update-rc.d set-hostname defaults`
# Remove the init script links with: `sudo /sbin/update-rc.d set-hostname remove`
#
# A .service file /run/systemd/generator.late/set-hostname.service got generated,
# supposedly as a result of running `update-rc.d`.

readonly DEBUG_ENABLED="FALSE"

start() {
	if [ "TRUE" == "${DEBUG_ENABLED}" ] ; then
		echo "ABTEST Before changing hostname, the value under /proc is: $(cat /proc/sys/kernel/hostname)"
	fi

	hostname $(cat /etc/hostname)
	if [ "0" != "${?}" ] ; then
		echo "Failed to set hostname to $(cat /etc/hostname)"
		exit 1
	fi

	if [ "TRUE" == "${DEBUG_ENABLED}" ] ; then
		echo "ABTEST runlevel is: $(/sbin/runlevel)"
	fi

	echo "Successfully set hostname to $(cat /etc/hostname)"

	if [ "TRUE" == "${DEBUG_ENABLED}" ] ; then
		echo "ABTEST After changing hostname, the value under /proc is: $(cat /proc/sys/kernel/hostname)"
	fi
}

stop() {
	echo "stop() function is not yet implemented"
}

case "${1}" in
	start)
		start
		;;
	stop)
		;;
	restart)
		start
		;;
	status)
		;;
	*)
		echo "Usage: $0 {start|restart}"
esac

