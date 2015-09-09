#!/bin/sh

PIDFILE=/var/run/jmxtrans/jmxtrans.pid
export HOSTNAME=$(hostname -f)

PARENT_DC=$(curl -s consul.service.consul:8500/v1/catalog/datacenters|jq ".[]"|grep -v ${DC_NAME})
if [ "X${PARENT_DC}" != "X" ];then 
    for ctmpl in $(ls /etc/consul-templates/jmxtrans.*);do
        echo "sed -i'' -E 's#service \'carbon(@\w+)?\'#service 'carbon@${ZK_DC}'#' ${ctmpl}"
        sed -i'' -E "s#service \"carbon(@\w+)?\"#service \"carbon@${ZK_DC}\"#" ${ctmpl}
    done
fi
echo "consul-template -once -consul consul.service.consul:8500 -template '/etc/consul-templates/jmxtrans.jvm.json.ctmpl:/var/lib/jmxtrans/jvm.json'"
consul-template -once -consul consul.service.consul:8500 -template "/etc/consul-templates/jmxtrans.jvm.json.ctmpl:/var/lib/jmxtrans/jvm.json"

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
