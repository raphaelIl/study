#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
for hostdomain in `cat ${OCP_HOSTNAME}`
do
    echo -e "-----------------------------------------------------------------------------------"
    echo -e "@@@[BASE PACKAGE INSTALL] ==> ${hostdomain}"
    ssh -tt root@$hostdomain  " \
        yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct vim; \
        yum -y update; \
        yum -y install openshift-ansible;"
       #yum -y install openshift-ansible-3.11.51;"
    echo -e "-----------------------------------------------------------------------------------"
done
echo -e "================================================================================[E]"
