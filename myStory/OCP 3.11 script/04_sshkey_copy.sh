#!/bin/sh

. ./00_env.sh

OCP=${OCP_IP_ALL}
if [ "e${1}" == "eHOST" ];
then
  OCP=${OCP_HOSTNAME_ALL}
fi
  

if [ -f "${HOME}/.ssh/id_rsa" ];
then
  echo -e "[S]================================================================================"
  for hostip in `cat ${OCP}`
    do
      echo -e "-----------------------------------------------------------------------------------"
      echo -e "@@@[HOSTNAME]"
      echo -e `cat /etc/hostname`
      echo -e "\n@@@[SSH KEY COPY] ==> ${hostip}"
      ssh-copy-id -i ~/.ssh/id_rsa.pub ${hostip}
      echo -e "-----------------------------------------------------------------------------------"
  done
  echo -e "================================================================================[E]"
  exit;
fi  

echo -e "[Generation public/private rsa key pair.]"
echo -e " \$ ssh-keygen"
