#!/bin/sh

if [ $(find /var/lib/jmxtrans/ -type f -name "*.json" |wc -l) -ne 0 ];then
    /usr/share/jmxtrans/bin/wrapper-linux-x86-64 /usr/share/jmxtrans/etc/wrapper.conf wrapper.syslog.ident=jmxtrans wrapper.pidfile=/var/run/jmxtrans/jmxtrans.pid wrapper.daemonize=FALSE
else
    echo "No jmxtrans JSON files to run with... exiting"
    sleep 2
    exit 0
fi
