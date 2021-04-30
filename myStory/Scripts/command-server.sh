#!/bin/bash
# Local -> SSH G/W -> Command Srv
USERNAME=$1
ENV=$2

fail() {
  cat <<-EOM
Usage: ${0##*/} [AD_ID] [environment]
e.g. ${0##*/} raphael.kim prod
EOM
  exit 1
}

if [ -z "${USERNAME}" ]; then
  fail
fi

if [ -z "${ENV}" ]; then
  fail
fi

if ! which expect > /dev/null; then
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
    send \"vault_ssh -u ${USERNAME} -p cmd -m dh\\r\"
    expect \"Password:\"
    send \"${PASSWORD}\\r\"
    sleep 0.5
    expect \"${USERNAME}@\"
    send \"ssh yadh@10.24.200.181\\r\"
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
    send \"vault_ssh -u ${USERNAME} -p cmd -m dh\\r\"
    expect \"Password:\"
    send \"${PASSWORD}\\r\"
    sleep 0.5
    expect \"${USERNAME}@\"
    send \"ssh yadh@dh-command.prod.yanolja.in\\r\"
    expect \"yadh@\"
    send \"sudo su - ${USERNAME}\\r\"
    interact
    "
    ;;
  *)
    fail
    ;;
esac
