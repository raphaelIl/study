#!/bin/bash
set -eo pipefail
ORIGINFILES="origin-master origin-master-api origin-master-controllers origin-node"
OCPFILES="atomic-openshift-master atomic-openshift-master-api atomic-openshift-master-controllers atomic-openshift-node"

die(){
  echo "$1"
  exit $2
}

usage(){
  echo "$0 [path]"
  echo "  path  The directory where the backup will be stored"
  echo "        /backup/\$(hostname)/\$(date +%Y%m%d) by default"
  echo "Examples:"
  echo "    $0 /my/mountpoint/\$(hostname)"
}

ocpfiles(){
  mkdir -p ${BACKUPLOCATION}/etc/sysconfig
  echo "Exporting OCP related files to ${BACKUPLOCATION}"
  cp -aR /etc/origin ${BACKUPLOCATION}/etc
  for file in ${ORIGINFILES} ${OCPFILES}
  do
    if [ -f /etc/sysconfig/${file} ]
    then
      cp -aR /etc/sysconfig/${file} ${BACKUPLOCATION}/etc/sysconfig/
    fi
  done
}

otherfiles(){
  mkdir -p ${BACKUPLOCATION}/etc/sysconfig
  mkdir -p ${BACKUPLOCATION}/etc/pki/ca-trust/source
  echo "Exporting other important files to ${BACKUPLOCATION}"
  if [ -f /etc/sysconfig/flanneld ]
  then
    cp -a /etc/sysconfig/flanneld \
      ${BACKUPLOCATION}/etc/sysconfig/
  fi
  cp -aR /etc/sysconfig/{iptables,docker-*} \
    ${BACKUPLOCATION}/etc/sysconfig/
  if [ -d /etc/cni ]
  then
    cp -aR /etc/cni ${BACKUPLOCATION}/etc/
  fi
  cp -aR /etc/dnsmasq* ${BACKUPLOCATION}/etc/
  cp -aR /etc/pki/ca-trust/source/anchors \
    ${BACKUPLOCATION}/etc/pki/ca-trust/source/
}

packagelist(){
  echo "Creating a list of rpms installed in ${BACKUPLOCATION}"
  rpm -qa | sort > ${BACKUPLOCATION}/packages.txt
}

etcd(){
  echo "Exporting ETCD Config & Data to ${BACKUPLOCATION}"
  cp -aR /etc/etcd/ ${BACKUPLOCATION}/etc
  
  mkdir -p /var/lib/etcd/backup-data/etcd-$(date +%Y%m%d)
  
  export ETCD_POD=$(oc get pods -n kube-system | grep -o -m 1 '\S*etcd\S*')
  export ETCD_POD_MANIFEST="/etc/origin/node/pods/etcd.yaml"
  export ETCD_EP=$(grep https ${ETCD_POD_MANIFEST} | cut -d '/' -f3)
  
  oc exec ${ETCD_POD} -c etcd -n kube-system -- /bin/bash -c "ETCDCTL_API=3 etcdctl \
  --cert /etc/etcd/peer.crt \
  --key /etc/etcd/peer.key \
  --cacert /etc/etcd/ca.crt \
  --endpoints $ETCD_EP \
  snapshot save /var/lib/etcd/backup-data/etcd-$(date +%Y%m%d)/etcd-db"
  
  cp -aR /var/lib/etcd/backup-data ${BACKUPLOCATION}/etc/etcd/
}

jenkins(){
  echo "Exporting Jenkins Build data to ${BACKUPLOCATION}"

  mkdir -p ${BACKUPLOCATION}/etc/jenkins_backup
  JENKINS_POD=$(oc get pod --all-namespaces --selector=deploymentconfig=jenkins -o jsonpath='{ .metadata.name }')
  JENKINS_DIR=$(oc get --all-namespaces dc/jenkins -o jsonpath='{ .spec.template.spec.containers[?(@.name=="jenkins")].volumeMounts[?(@.name=="jenkins-data")].mountPath }')

  oc rsync $JENKINS_POD:$JENKINS_DIR ${BACKUPLOCATION}/etc/jenkins_backup
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  usage
  exit 0
fi

BACKUPLOCATION=${1:-"/backup/$(hostname)/$(date +%Y%m%d-%H%M)"}

mkdir -p ${BACKUPLOCATION}

ocpfiles
otherfiles
packagelist
etcd
# jenkins

exit 0



=========================




Backing up registry certificates

cd /etc/docker/certs.d/
tar cf /tmp/docker-registry-certs-$(hostname).tar *


Backing up application data

1. Get the application data mountPath from the deploymentconfig

oc get dc/jenkins -o jsonpath='{ .spec.template.spec.containers[?(@.name=="jenkins")].volumeMounts[?(@.name=="jenkins-data")].mountPath }'
/var/lib/jenkins

2. Get the name of the pod that is currently running:

$ oc get pod --selector=deploymentconfig=jenkins -o jsonpath='{ .metadata.name }'
jenkins-1-37nux

3. Use the oc rsync command to copy application data:

$ oc rsync jenkins-1-37nux:/var/lib/jenkins /tmp/





Backing up etcd

etcd backup Configuration

mkdir -p /backup/etcd-config-$(date +%Y%m%d)/
cp -R /etc/etcd/ /backup/etcd-config-$(date +%Y%m%d)/

check etcd endpoints

ETCDCTL_API=3 etcdctl --cert="/etc/etcd/peer.crt" \
--key=/etc/etcd/peer.key \
--cacert="/etc/etcd/ca.crt" \
--endpoints="https://*master-0.example.com*:2379,\
https://*master-1.example.com*:2379,\
https://*master-2.example.com*:2379"
endpoint health


etcd backup data

1. Obtain the etcd endpoint IP address from the static pod manifest:

export ETCD_POD_MANIFEST="/etc/origin/node/pods/etcd.yaml"
export ETCD_EP=$(grep https ${ETCD_POD_MANIFEST} | cut -d '/' -f3)

2. Obtain the etcd pod name:

oc login -u system:admin
export ETCD_POD=$(oc get pods -n kube-system | grep -o -m 1 '\S*etcd\S*')

3. Take a snapshot of the etcd data in the pod and store it locally:

# oc project kube-system
oc exec ${ETCD_POD} -c etcd -n kube-system -- /bin/bash -c "ETCDCTL_API=3 etcdctl \
--cert /etc/etcd/peer.crt \
--key /etc/etcd/peer.key \
--cacert /etc/etcd/ca.crt \
--endpoints $ETCD_EP \
snapshot save /var/lib/etcd/snapshot.db"


Project backup

To export the project objects into a project.yaml file:

oc get -o yaml --export all > project.yaml

Export the project’s role bindings, secrets, service accounts, and persistent volume claims:


for object in rolebindings serviceaccounts secrets imagestreamtags cm egressnetworkpolicies rolebindingrestrictions limitranges resourcequotas pvc templates cronjobs statefulsets hpa deployments replicasets poddisruptionbudget endpoints
do
  oc get -o yaml --export $object > $object.yaml
done


To list all the namespaced objects:

oc api-resources --namespaced=true -o name




Backing up persistent volume claims

You can synchronize persistent data from inside of a container to a server.

음 이건 좀 너무 큰 일인데...?
