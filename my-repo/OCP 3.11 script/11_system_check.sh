#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
for hostdomain in `cat ${OCP_HOSTNAME}`
do
    echo -e "-----------------------------------------------------------------------------------"
    echo -e "@@@[SYSTEM CHECK] ==> ${hostdomain}"
    ssh -tt root@$hostdomain " \
    echo -e '----- [RHEL Version Check : ${hostdomain}]'; cat /etc/redhat-release; \
    echo -e '\n----- [hostname : ${hostdomain}]'; hostname; \
    echo -e '\n----- [Selinux Check : ${hostdomain}]'; sestatus; \
    echo -e '\n----- [NetworkManager Check : ${hostdomain}]'; systemctl is-active NetworkManager; \
    echo -e '\n----- [Docker Check : ${hostdomain}]'; lvs | grep docker-pool; systemctl is-active docker; \
    echo -e '\n----- [yum repo Check : ${hostdomain}]'; yum repolist; \
    echo -e '\n----- [chronyc Check : ${hostdomain}]'; chronyc sources -v;" 
    echo "================================================================================"
done