#!/bin/sh
exec /usr/sbin/init

# Start services
systemctl start rpcidmapd
systemctl start rpcbind
systemclt start  autofs

# Kill autofs pid and restart, because Linux
ps -ef | grep '/usr/sbin/automount' | awk '{print $2}' | xargs kill -9
systemclt start  autofs
/usr/sbin/automount --foreground --dont-check-daemon &
