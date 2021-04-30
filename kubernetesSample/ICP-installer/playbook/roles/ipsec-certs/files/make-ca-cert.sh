#!/bin/bash

# Licensed Materials - Property of IBM
# 5737-E67
# @ Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

set -o errexit
set -o nounset
set -o pipefail

base_dir=$(cd $(dirname $0) && pwd)

cert_dir=${CERT_DIR:-/srv/kubernetes}

mkdir -p "$cert_dir"

tmpdir=$(mktemp -d -t kubernetes_cacert.XXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT
cd "${tmpdir}"

if [ -f $base_dir/easy-rsa.tar.gz ]; then
	ln -s $base_dir/easy-rsa.tar.gz .
fi
tar xzf easy-rsa.tar.gz > /dev/null 2>&1

## Generate Root CA
cd easy-rsa-master/easyrsa3
./easyrsa init-pki > /dev/null 2>&1
./easyrsa --batch "--req-cn=tmp.icp" build-ca nopass > /dev/null 2>&1

# Replace Root CA
cp $ROOT_CA_CRT pki/ca.crt
cp $ROOT_CA_KEY pki/private/ca.key
## Generate Root CA end

./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn=ipsec-mesh --req-org= \
  --req-c= --req-st= --req-city= --req-email= --req-ou= \
  build-client-full ipsec-mesh nopass > /dev/null 2>&1

cp -p pki/issued/ipsec-mesh.crt "${cert_dir}/ipsec-mesh.crt"
cp -p pki/private/ipsec-mesh.key "${cert_dir}/ipsec-mesh.key"