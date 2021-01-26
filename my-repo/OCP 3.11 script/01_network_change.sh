#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
for hostip in `cat ${OCP_IP_ALL}`
do
    echo -e "-----------------------------------------------------------------------------------"
    echo -e "@@@[HOST NETWORK CONFIGRUE] ==> ${hostip}"
    ssh -tt root@${hostip}  " \
        nmcli con mod ${NW_NAME} connection.id ${NW_NAME}; \
	nmcli con mod ${NW_NAME} ipv4.addr ${hostip}/${NW_PREFIX}; \
	nmcli con mod ${NW_NAME} ipv4.gateway ${NW_GATEWAY}; \
	nmcli con mod ${NW_NAME} ipv4.dns ${NW_DNS1}; \
	nmcli con mod ${NW_NAME} ipv4.dns-search ${NW_DNS_SEARCH}; \
        nmcli con mod ${NW_NAME} ipv4.method manual; \
        nmcli con mod ${NW_NAME} ipv6.method ignore; \
	nmcli con reload; \
	systemctl restart network; \
        nmcli con show ${NW_NAME} | grep -i ipv4;"
    echo -e "-----------------------------------------------------------------------------------"
done
echo -e "================================================================================[E]"

#for hostip in `cat ocpips`
#do
#    echo "================================================================================"
#    echo "----- HOST NETWORK CONFIGRUE -----"
#    ssh -tt root@${hostip}  "echo 'HOSTNAME : '`hostNW_NAME`; \
#        nmcli con mod ${NW_NAME} connection.id ${NW_NAME}; \
#        nmcli con mod ${NW_NAME} ipv4.addr ${hostip}/${prefix}; \
#        nmcli con mod ${NW_NAME} ipv4.gateway ${gateway}; \
#        nmcli con mod ${NW_NAME} ipv4.dns ${dns1}; \
#        nmcli con mod ${NW_NAME} +ipv4.dns ${dns2}; \
#        nmcli con mod ${NW_NAME} ipv4.dns-search ${dns_search}; \
#        nmcli con mod ${NW_NAME} ipv4.method manual; \
#        nmcli con mod ${NW_NAME} ipv6.method ignore; \
#        nmcli con mod ${NW_NAME} tu ${mtu}; \
#        nmcli con reload; \
#        systemctl restart network; \
#        nmcli con show ${NW_NAME} | grep -i ipv4;"
#    echo "================================================================================"
#done
