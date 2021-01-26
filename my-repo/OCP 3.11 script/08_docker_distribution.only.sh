#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
sed "s/###ROOTDIRECTORY###/${ROOTDIRECTORY}/g" ${BASE_DIR}/config/config.sample > ${BASE_DIR}/config/config.temp1
sed "s/###DD_ADDR###/${DD_ADDR}/g" ${BASE_DIR}/config/config.temp1 > ${BASE_DIR}/config/config.temp2
sed "s/###DD_PORT###/${DD_PORT}/g" ${BASE_DIR}/config/config.temp2 > ${BASE_DIR}/config/config.temp1
sed "s/###CERT_PATH###/${CERT_PATH}/g" ${BASE_DIR}/config/config.temp1 > ${BASE_DIR}/config/config.yml

echo -e "-----------------------------------------------------------------------------------"
echo -e "@@@[DOCKER DISTRIBUTION INSTALL] ==> ${DD_IP}"

ssh -tt root@${DD_IP} "echo -e '@@@[HOSTNAME]' ;cat /etc/hostname; \
echo -e '\n@@@[DOCKER-DISTRIBUTION INSTALL]'; \
yum repolist; \
yum -y install docker-distribution; \
echo -e '\n@@@[CONFIGURATION COPY]'; \
scp ${INSTALL_USER}@${BASE_IP}:${BASE_DIR}/config/config.yml /etc/docker-distribution/registry/config.yml; \
echo -e '\n@@@[PORT OPEN]'; \
iptables -I INPUT -m state --state NEW -p tcp -m tcp --dport ${DD_PORT} -j ACCEPT; \
iptables-save > /etc/sysconfig/iptables; \
echo -e '\n@@@[SERVICE START]'; \
systemctl enable docker docker-distribution; \
systemctl restart docker; \
systemctl restart docker-distribution; "

echo -e "-----------------------------------------------------------------------------------"
echo -e "================================================================================[E]"
