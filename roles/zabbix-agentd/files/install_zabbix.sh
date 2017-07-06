#!/bin/bash

yum install -y gcc make libselinux-python

grep -q "zabbix" /etc/group

if [ $? == 1];then
	groupadd zabbix
fi

grep -q "zabbix" /etc/passwd
if [ $? == 1 ];then
	useradd zabbix
fi

mv /usr/local/zabbix /usr/local/zabbix_old-`date +%F`
rm -rf /etc/zabbix 2&1>/dev/null

cd /tmp
tar zxf zabbix.tar.gz
cd zabbix
./configure --prefix=/usr/local/zabbix --enable-agent
make && make install 
ln -s /usr/local/zabbix/etc /etc/zabbix
ln -s /usr/local/zabbix/sbin/zabbix_agentd /usr/local/sbin/zabbix_agentd
cp misc/init.d/fedroa/care/zabbix_agentd /etc/init.d
cp /etc/zabbix/zabbix_ageentd.conf /etc/zabbix/zabbix_ageentd.conf-`date +%F`

cat >/etc/zabbix/zabbix_agentd.conf<<EOF
PidFile=/tmp/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_ageentd.log
Server=127.0.0.1
ServerActive=127.0.0.1
ListenPort=10050
ListenIP=0.0.0.0
EnableRemoteCommands=1
UnsafeUserParameters=1
LogFileSize=10
Timeout=30
EOF

/etc/init.d/zabbix_agentd start
chkconfig zabbix_agentd on
