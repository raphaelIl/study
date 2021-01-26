#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
for hostdomain in `cat ${OCP_HOSTNAME}`
do
    echo -e "-----------------------------------------------------------------------------------"
    echo -e "@@@[DOCKER SETTING] ==> ${hostdomain}"
    ssh -tt root@$hostdomain  " \
        yum -y install docker; \
        echo 'DEVS=${DOCKER_DEVS}' > /etc/sysconfig/docker-storage-setup; \
        echo 'VG=docker-vg' >> /etc/sysconfig/docker-storage-setup; \
        echo 'WIPE_SIGNATURES=true' >> /etc/sysconfig/docker-storage-setup; \
        docker-storage-setup; \
        systemctl enable docker; \
        systemctl restart docker; "
    echo -e "-----------------------------------------------------------------------------------"
done
echo -e "================================================================================[E]"
