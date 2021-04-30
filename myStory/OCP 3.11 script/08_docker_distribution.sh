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
yum -y install docker docker-distribution; \
echo -e '\n@@@[CERTIFICATE CREATE]'; \
mkdir -p /volumes/cert; \
openssl genrsa -des3 -out ${CERT_PATH}/${DD_ADDR}.key 2048; \
openssl req -new -key ${CERT_PATH}/${DD_ADDR}.key -out ${CERT_PATH}/${DD_ADDR}.csr; \
cp ${CERT_PATH}/${DD_ADDR}.key ${CERT_PATH}/${DD_ADDR}.key.origin; \
openssl rsa -in ${CERT_PATH}/${DD_ADDR}.key.origin -out ${CERT_PATH}/${DD_ADDR}.key; \
openssl x509 -req -days 3650 -in ${CERT_PATH}/${DD_ADDR}.csr -signkey ${CERT_PATH}/${DD_ADDR}.key -out ${CERT_PATH}/${DD_ADDR}.crt; \
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
