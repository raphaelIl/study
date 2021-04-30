#!/bin/bash

# Licensed Materials - Property of IBM
# 5737-E67
# @ Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

set -o errexit
set -o nounset
set -o pipefail

base_dir=$(cd $(dirname $0) && pwd)

cert_ip=$1
nodes=$2
sans="DNS:$1"

mkdir -p "$CERT_DIR"

tmpdir=$(mktemp -d -t etcd_cacert.XXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT
cd "${tmpdir}"

if [ -f $base_dir/easy-rsa.tar.gz ]; then
	ln -s $base_dir/easy-rsa.tar.gz .
fi
tar xzf easy-rsa.tar.gz > /dev/null 2>&1

cd easy-rsa-master/easyrsa3
./easyrsa init-pki > /dev/null 2>&1
./easyrsa --batch --days=36500 "--req-cn=$cert_ip" build-ca nopass > /dev/null 2>&1

cp pki/ca.crt "${CERT_DIR}/ca.pem"
cp pki/private/ca.key "${CERT_DIR}/ca-key.pem"

for node in ${nodes//,/ }; do
    sans="$sans,IP:$node"
done

./easyrsa --dn-mode=org \
  --subject-alt-name=$sans \
  --days=36500 \
  --req-cn=$cert_ip \
  --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-server-full $cert_ip nopass > /dev/null 2>&1

cp pki/issued/${cert_ip}.crt "${CERT_DIR}/server.pem"
cp pki/private/${cert_ip}.key "${CERT_DIR}/server-key.pem"

rm -f pki/issued/${cert_ip}.crt pki/private/${cert_ip}.key pki/reqs/${cert_ip}.req
rm -f pki/index.txt
touch pki/index.txt

./easyrsa --dn-mode=org \
  --subject-alt-name=$sans \
  --days=36500 \
  --req-cn=$cert_ip \
  --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full $cert_ip nopass > /dev/null 2>&1

cp pki/issued/${cert_ip}.crt "${CERT_DIR}/client.pem"
cp pki/private/${cert_ip}.key "${CERT_DIR}/client-key.pem"

rm -f pki/issued/${cert_ip}.crt pki/private/${cert_ip}.key pki/reqs/${cert_ip}.req
rm -f pki/index.txt
touch pki/index.txt

for node in ${nodes//,/ }; do
    ./easyrsa --dn-mode=org \
      --subject-alt-name="IP:$node" \
      --days=36500 \
      --req-cn=$cert_ip \
      --req-org= \
      --req-c= --req-st= --req-city= --req-email= --req-ou= \
      build-server-full $cert_ip nopass > /dev/null 2>&1
    cp pki/issued/${cert_ip}.crt "${CERT_DIR}"/member-${node}.pem
    cp pki/private/${cert_ip}.key "${CERT_DIR}"/member-${node}-key.pem
    rm -f pki/issued/${cert_ip}.crt pki/private/${cert_ip}.key pki/reqs/${cert_ip}.req
    rm -f pki/index.txt
    touch pki/index.txt
done
