#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"


echo -e "-----------------------------------------------------------------------------------"
echo -e "@@@[CHRONY INSTALL] ==> ${CHRONY_SERVER}"
ssh -tt root@${CHRONY_SERVER} " \
Asystemctl stop ntpd; \
systemctl disable ntpd; \
yum -y remove ntp; \
yum -y install chrony; \
iptables -I INPUT -m state --state NEW -p udp -m udp --dport 123 -j ACCEPT; \
iptables-save > /etc/sysconfig/iptables; \
systemctl enable chronyd; \
systemctl restart chronyd; \
chronyc sources -v; \
chronyc tracking;"

for hostdomain in `cat ${OCP_HOSTNAME_ALL}`
do
    echo -e "-----------------------------------------------------------------------------------"
    echo -e "@@@[CHRONY SETTING] ==> ${hostdomain}"
    ssh -tt root@${hostdomain} " \
    timedatectl set-timezone Asia/Seoul; \
    timedatectl status; \
    yum -y remove ntp; \
    yum -y install chrony; \
    sed -i 's/^server/#server/g' /etc/chrony.conf; \
    echo 'server ${CHRONY_SERVER} iburst' >> /etc/chrony.conf; \
    systemctl enable chronyd; \
    systemctl restart chronyd; \
    chronyc sources -v; \
    chronyc tracking;"
    echo -e "-----------------------------------------------------------------------------------"
done
echo -e "================================================================================[E]"
