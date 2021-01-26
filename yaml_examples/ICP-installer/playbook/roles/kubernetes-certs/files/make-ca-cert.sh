#!/bin/bash

# Licensed Materials - Property of IBM
# 5737-E67
# @ Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

set -o errexit
set -o nounset
set -o pipefail

base_dir=$(cd $(dirname $0) && pwd)

DEBUG="${DEBUG:-false}"

if [ "${DEBUG}" == "true" ]; then
	set -x
fi

cert_ip=$1
extra_sans=${2:-}
cert_dir=${CERT_DIR:-/srv/kubernetes}

mkdir -p "$cert_dir"

use_cn=false

sans="IP:${cert_ip}"
if [[ -n "${extra_sans}" ]]; then
  sans="${sans},${extra_sans}"
fi

tmpdir=$(mktemp -d -t kubernetes_cacert.XXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT
cd "${tmpdir}"

# TODO: For now, this is a patched tool that makes subject-alt-name work, when
# the fix is upstream  move back to the upstream easyrsa.  This is cached in GCS
# but is originally taken from:
#   https://github.com/brendandburns/easy-rsa/archive/master.tar.gz
#
# To update, do the following:
# curl -o easy-rsa.tar.gz https://github.com/brendandburns/easy-rsa/archive/master.tar.gz
# gsutil cp easy-rsa.tar.gz gs://kubernetes-release/easy-rsa/easy-rsa.tar.gz
# gsutil acl ch -R -g all:R gs://kubernetes-release/easy-rsa/easy-rsa.tar.gz
#
# Due to GCS caching of public objects, it may take time for this to be widely
# distributed.
#
# Use ~/kube/easy-rsa.tar.gz if it exists, so that it can be
# pre-pushed in cases where an outgoing connection is not allowed.
if [ -f $base_dir/easy-rsa.tar.gz ]; then
	ln -s $base_dir/easy-rsa.tar.gz .
fi
tar xzf easy-rsa.tar.gz > /dev/null 2>&1

## Generate Root CA
cd easy-rsa-master/easyrsa3
./easyrsa init-pki > /dev/null 2>&1
./easyrsa --batch "--req-cn=$cert_ip@`date +%s`" build-ca nopass > /dev/null 2>&1

# Replace Root CA
cp $ROOT_CA_CRT pki/ca.crt
cp $ROOT_CA_KEY pki/private/ca.key
## Generate Root CA end

if [ $use_cn = "true" ]; then
    ./easyrsa --days=36500 build-server-full $cert_ip nopass > /dev/null 2>&1
    cp -p pki/issued/$cert_ip.crt "${cert_dir}/server.cert" > /dev/null 2>&1
    cp -p pki/private/$cert_ip.key "${cert_dir}/server.key" > /dev/null 2>&1
else
    ./easyrsa --days=36500 --subject-alt-name="${sans}" build-server-full kubernetes-master nopass > /dev/null 2>&1
    cp -p pki/issued/kubernetes-master.crt "${cert_dir}/server.cert" > /dev/null 2>&1
    cp -p pki/private/kubernetes-master.key "${cert_dir}/server.key" > /dev/null 2>&1
fi
# Make a superuser client cert with subject "O=system:masters, CN=kubecfg"
./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=kubecfg --req-org=system:masters \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full kubecfg nopass > /dev/null 2>&1
# Build certs for kubelet and kube-proxy.
./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=kubelet --req-org=system:nodes \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full kubelet nopass > /dev/null 2>&1
./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=kubelet-client --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full kubelet-client nopass > /dev/null 2>&1
./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=system:kube-proxy --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full system:kube-proxy nopass > /dev/null 2>&1
./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=system:kube-scheduler --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full system:kube-scheduler nopass > /dev/null 2>&1
./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=system:kube-controller-manager --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full system:kube-controller-manager nopass > /dev/null 2>&1
cp -p pki/issued/kubecfg.crt "${cert_dir}/kubecfg.crt"
cp -p pki/private/kubecfg.key "${cert_dir}/kubecfg.key"
cp -p pki/issued/kubelet.crt "${cert_dir}/kubelet.crt"
cp -p pki/private/kubelet.key "${cert_dir}/kubelet.key"
cp -p pki/issued/system:kube-proxy.crt "${cert_dir}/kube-proxy.crt"
cp -p pki/private/system:kube-proxy.key "${cert_dir}/kube-proxy.key"
cp -p pki/issued/kubelet-client.crt "${cert_dir}/kubelet-client.crt"
cp -p pki/private/kubelet-client.key "${cert_dir}/kubelet-client.key"
cp -p pki/issued/system:kube-scheduler.crt "${cert_dir}/kube-scheduler.crt"
cp -p pki/private/system:kube-scheduler.key "${cert_dir}/kube-scheduler.key"
cp -p pki/issued/system:kube-controller-manager.crt "${cert_dir}/kube-controller-manager.crt"
cp -p pki/private/system:kube-controller-manager.key "${cert_dir}/kube-controller-manager.key"
