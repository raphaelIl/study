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

sans=${1:-}
ADMIN_USER=${ADMIN_USER:-admin}
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
  --subject-alt-name="${sans}" \
  --days=36500 \
  --req-cn=tiller-server \
  --req-c=US \
  --req-st="New York" \
  --req-city="Armonk" \
  --req-org="IBM Private Cloud" \
  --req-email= \
  --req-ou= \
  build-server-full tiller nopass > /dev/null 2>&1

./easyrsa --dn-mode=org \
  --days=36500 \
  --req-cn="$ADMIN_USER" \
  --req-c=US \
  --req-st="New York" \
  --req-city="Armonk" \
  --req-org="system:masters" \
  --req-email= \
  --req-ou= \
  build-client-full $ADMIN_USER nopass > /dev/null 2>&1

cp -p pki/issued/tiller.crt "${cert_dir}/tiller.crt"
cp -p pki/private/tiller.key "${cert_dir}/tiller.key"

cp -p pki/issued/$ADMIN_USER.crt "${cert_dir}/admin.crt"
cp -p pki/private/$ADMIN_USER.key "${cert_dir}/admin.key"
