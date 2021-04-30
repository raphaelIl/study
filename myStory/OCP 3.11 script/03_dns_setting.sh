#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
echo -e "-----------------------------------------------------------------------------------"
ssh -tt root@${DNS_IP} "echo -e '@@@[HOSTNAME]' ;cat /etc/hostname; \
yum -y install bind bind-utils; \
rm -vf /var/named/K${DNS_DOMAIN}*; \
pushd /var/named; \
dnssec-keygen -a HMAC-SHA256 -b 256 -n USER -r /dev/urandom ${DNS_DOMAIN}; \
grep Key: K${DNS_DOMAIN}*.private | cut -d ' ' -f 2 \
| sed 's/^/secret\ \"/' \
| sed 's/$/\";};/' \
| sed -e '1 ikey\ ${DNS_DOMAIN}\ {' \
| sed -e '2 ialgorithm HMAC-SHA256;' \
> /var/named/${DNS_DOMAIN}.key; \
popd
rndc-confgen -a -r /dev/urandom; \
restorecon -v /etc/rndc.* /etc/named.*; \
chown -v root:named /etc/rndc.key; \
chmod -v 640 /etc/rndc.key; \
restorecon -v /var/named/forwarders.conf; \
chmod -v 755 /var/named/forwarders.conf; \
rm -rvf /var/named/dynamic; \
mkdir -vp /var/named/dynamic;"

echo -e "\n@@@[REPO FILE COPY] ==> ${DNS_IP}"
scp ${BASE_DIR}/config/dns/zone.db root@${DNS_IP}:/var/named/dynamic/${DNS_DOMAIN}.db
scp ${BASE_DIR}/config/dns/rr.zone root@${DNS_IP}:/var/named/dynamic/${DNS_DOMAIN}.rr.zone
scp ${BASE_DIR}/config/dns/named.conf root@${DNS_IP}:/etc/named.conf

ssh -tt root@${DNS_IP} "echo -e '\n@@@[HOSTNAME]' ;cat /etc/hostname; \
chgrp named -R /var/named; \
chown named -R /var/named/dynamic; \
restorecon -rv /var/named; \
chown -v root:named /etc/named.conf; \
restorecon /etc/named.conf; \
systemctl enable named; \
systemctl restart named; \
systemctl status -l named; \
yum -y install iptables-services; \
systemctl enable iptables; \
systemctl restart iptables; \
iptables-save > /etc/sysconfig/iptables.save.${DATETIME}; \
iptables -I INPUT -p tcp -m tcp --dport 53 -j ACCEPT; \
iptables -I INPUT -p udp -m udp --dport 53 -j ACCEPT; \
service iptables save; "
echo -e "-----------------------------------------------------------------------------------"
echo -e "================================================================================[E]"
