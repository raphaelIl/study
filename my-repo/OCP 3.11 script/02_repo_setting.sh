#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
sed "s/###REPO_IP###/${REPO_IP}/g" ${BASE_DIR}/config/ocp311.sample > ${BASE_DIR}/config/ocp311.repo

echo -e "-----------------------------------------------------------------------------------"
for hostip in `cat ${OCP_IP}`
  do
    echo -e "-----------------------------------------------------------------------------------"
    echo -e "@@@[REPO FILE COPY] ==> ${hostip}"
    scp ${BASE_DIR}/config/ocp311.repo root@${hostip}:/etc/yum.repos.d/ocp311.repo
    echo -e "\n@@@[REPO SETTING] ==> ${hostip}"
    ssh -tt root@${hostip} "yum clean all; \
    yum repolist;"
    echo -e "-----------------------------------------------------------------------------------"
done

echo -e "-----------------------------------------------------------------------------------"
echo -e "================================================================================[E]"



#firewall-cmd --permanent --add-service=http; \
#firewall-cmd --reload; \
