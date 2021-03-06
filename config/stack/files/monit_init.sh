#!/bin/sh
### BEGIN INIT INFO
# Provides:          monit
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: service and resource monitoring daemon
### END INIT INFO
# /etc/init.d/monit start and stop monit daemon monitor process.
# Fredrik Steen, stone@debian.org
# Stefan Alfredsson, alfs@debian.org

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/monit
CONFIG="/etc/monit/monitrc"
DELAY="/etc/monit/monit_delay"
NAME=monit
DESC="daemon monitor"

set -e

# Check if DAEMON binary exist
test -f $DAEMON || exit 0

if [ -f "/etc/default/monit" ]; then
     . /etc/default/monit
fi

ARGS="-p /var/lib/monit/$NAME.pid -c $CONFIG -s /var/lib/monit/monit.state -d 60"

monit_check_config () {
    # Check for emtpy config, probably default configfile.
    if [ "`grep -s -v \"^#\" $CONFIG`" = "" ]; then
        echo "empty config, please edit $CONFIG."
        exit 0
    fi
}

monit_check_perms () {
    # Check the permission on configfile. 
    # The permission must not have more than -rwx------ (0700) permissions.
   
    # Skip checking, fix perms instead.
    /bin/chmod go-rwx $CONFIG

}

monit_delayed_monitoring () {
    if [ -x $DELAY ]; then
      $DELAY &
    elif [ -f $DELAY ]; then
      echo
      echo "[WARNING] A delayed start file exists ($DELAY) but it is not executable."
    fi
}

monit_check_syntax () {
  sudo -u deploy $DAEMON -t -c $CONFIG;
#  if [ $? ] ; then
#      echo "syntax good"
#  else
#      echo "syntax bad"
#  fi
}


monit_checks () {
    # Check for emtpy configfile
    monit_check_config
    # Check permissions of configfile
    monit_check_perms
}

case "$1" in
  start)
	echo -n "Starting $DESC: "
    monit_checks $1
	echo -n "$NAME"
        start-stop-daemon --start --quiet -c deploy --pidfile /var/lib/monit/$NAME.pid \
		--exec $DAEMON > /dev/null 2>&1 -- $ARGS
   monit_delayed_monitoring
	echo "."
	;;
  stop)
	echo -n "Stopping $DESC: "
    #monit_checks $1
	echo -n "$NAME"
        start-stop-daemon --retry 5 --oknodo --stop -c deploy --quiet --pidfile /var/lib/monit/$NAME.pid \
		--exec $DAEMON  > /dev/null 2>&1
	echo "."
	;;
  restart|force-reload)
	$0 stop
	$0 start
	;;
  syntax)
   monit_check_syntax
   ;;
  *)
	N=/etc/init.d/$NAME
	echo "Usage: $N {start|stop|restart|force-reload|syntax}" >&2
	exit 1
	;;
esac

exit 0
