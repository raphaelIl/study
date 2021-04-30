#!/bin/bash
# Local -> SSH G/W -> Worker
USERNAME=$1
ENV=$2
NODE=$3

fail() {
  cat <<-EOM
Usage: ${0##*/} [AD_ID] [environment] [private ip]
e.g. ${0##*/} raphael.kim dev ip-10-xxx.ap-northeast-2.compute.internal
EOM
  exit 1
}

if [ -z "${USERNAME}" ]; then
  fail
fi

if [ -z "${ENV}" ]; then
  fail
fi

if [ -z "${NODE}" ]; then
  fail
fi

which expect > /dev/null
if [ "$?" -ne 0 ]; then
  echo "You should install expect binary: 'brew install expect'"
  exit 1
fi

echo -n Enter password:
read -sr PASSWORD
echo

case $ENV in
  dev)
    expect -c "
    spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USERNAME}@gw.dev.yanolja.in
    expect \"password:\"
    send \"${PASSWORD}\\r\"
    expect \"${USERNAME}@\"
    send \"vault_ssh -u ${USERNAME}\\r\"
    expect \"Password:\"
    send \"${PASSWORD}\\r\"
    sleep 1
    expect \"${USERNAME}@\"
    send \"ssh yanolja@${NODE}\\r\"
    interact
    "
    ;;
  prod)
    echo -n OTP Code:
    read -sr otp_code
    echo

    expect -c "
    spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USERNAME}@gw.yanolja.in
    expect \"Password:\"
    send \"${PASSWORD}\\r\"
    expect \"One-Time Code\"
    send \"${otp_code}\\r\"
    expect \"${USERNAME}@\"
    send \"vault_ssh -u ${USERNAME}\\r\"
    expect \"Password:\"
    send \"${PASSWORD}\\r\"
    sleep 1
    expect \"${USERNAME}@\"
    send \"ssh yanolja@${NODE}\\r\"
    interact
    "
    ;;
  *)
    fail
    ;;
esac