#!/bin/sh

. ./00_env.sh

echo -e "[S]================================================================================"
echo -e "@@@[OCP Clean (docker uninstall, remove directorys, lv/vg/pvremove)]"
while [ 1 ]
do
        read -p "Continew? (Y/N) ? : " input
        case ${input} in
                y|Y)
			for hostdomain in `cat ${OCP_HOSTNAME}`
			do
				echo -e "-----------------------------------------------------------------------------------"
				echo -e "@@@[CLEAN NODES] ==> ${hostdomain}"
				ssh -tt root@$hostdomain  " \
					echo -e "@@@[STOP DOCKER]"; \
					systemctl stop docker; \
					systemctl disable docker; \
					echo -e "@@@[REMOVE PACKAGE]"; \
					yum -y remove openshift *openshift-* docker*; \
					echo -e "@@@[REMOVE DIRECTORYS]"; \
					rm -rf /etc/origin /var/lib/openshift /etc/sysconfig/atomic-openshift* /etc/sysconfig/docker* /var/lib/docker/* /root/.kube/config /etc/ansible/facts.d /usr/share/openshift; \
					echo -e "@@@[REMOVE LV, VG, PV]"; \
					lvremove -y dockerlv; \
					vgremove -y dockervg; \
					pvremove -y ${DOCKER_DEVS}1; \
					echo -e "@@@[REMOVE PARTITION]"; \
					parted ${DOCKER_DEVS} rm 1; "
				echo -e "-----------------------------------------------------------------------------------"
			done
                        break;;
                n|N)
                        echo -e "@@@[CANCLE]"
                        break;;
                *)
                        echo "Please enter one of the following:[Y/N]";;
        esac
done
echo "================================================================================"

