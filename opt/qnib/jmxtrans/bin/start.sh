#!/bin/sh

PIDFILE=/var/run/jmxtrans/jmxtrans.pid

function stop_jmxtrans {
    echo "Stop jmxtrans..."
    kill -9 $(cat ${PIDFILE})
    exit
}

trap "stop_jmxtrans" SIGINT SIGTERM

sed -i'' -e "s/\"host\" \: \"HOST.*/\"host\" \: \"$(hostname -f)\",/" /var/lib/jmxtrans/*.json

if [ $(find /var/lib/jmxtrans/ -type f -name "*.json" |wc -l) -ne 0 ];then
    /usr/share/jmxtrans/bin/wrapper-linux-x86-64 /usr/share/jmxtrans/etc/wrapper.conf wrapper.syslog.ident=jmxtrans wrapper.pidfile=${PIDFILE} wrapper.daemonize=FALSE
else
    echo "No jmxtrans JSON files to run with... exiting"
    sleep 2
    exit 0
fi
