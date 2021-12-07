#!/usr/bin/env bash
# Local Get AWS credentials via SAML
# https://aws.amazon.com/ko/blogs/security/how-to-implement-federated-api-and-cli-access-using-saml-2-0-and-ad-fs/
# https://github.com/Versent/saml2aws
# https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/troubleshoot_saml_view-saml-response.html

echo 'Choose ENV'
echo 'e.g. stg or prod'
echo -n ENV:
read -r ENV
echo

echo 'Choose Target Role'
echo 'e.g. SSO-Dev-Admin or SSO-Dev-Develop or SSO-Prod-Admin or SSO-Prod-Develop or SSO-Prod-Develop-Approval'
echo -n ROLE:
read -r ROLE
echo

checkParameter() {
  cat <<-EOM
Usage: ${0##*/} [environment] [TARGET_ROLE]
e.g. ${0##*/} stg SSO-Dev-Admin
EOM
  exit 1
}

checkPackage() {
  if ! which "$1" > /dev/null 2>&1; then
    echo "Error: '$1' is not installed"
    echo "brew install '$1'"
    exit 1
  fi
}

checkFile() {
  if [ -f "$1" ]; then
    cp "$1" "$1.bak"
  else
    mkdir ~/.aws
    touch "$1"
    cat <<-EOM > "$1"
[default]
region = ap-northeast-2
output = json
EOM
  fi
}

if [ -z "${ROLE}" ] || [ -z "${ENV}" ]; then
  checkParameter
fi

if [ ! -e "$HOME/.aws/samlResponse" ]; then
  echo "plz ready to $HOME/.aws/samlResponse file"
  exit 1
fi

checkFile ~/.aws/credentials
checkFile ~/.aws/config
checkPackage aws
checkPackage jq

createCredential() {
  aws sts assume-role-with-saml \
  --role-arn "${role}" \
  --principal-arn "${trustRelation}" \
  --saml-assertion file://.aws/samlResponse > /tmp/credentials.json

  AccessKeyId=$(cat /tmp/credentials.json | jq .Credentials.AccessKeyId | tr -d '""')
  SecretAccessKey=$(cat /tmp/credentials.json | jq .Credentials.SecretAccessKey | tr -d '""')
  SessionToken=$(cat /tmp/credentials.json | jq .Credentials.SessionToken | tr -d '""')

  cat <<-EOM > ~/.aws/credentials
[default]
aws_access_key_id = ${AccessKeyId}
aws_secret_access_key = ${SecretAccessKey}
aws_session_token = ${SessionToken}
EOM

rm -f /tmp/credentials.json
echo "If you wanna check result: 'aws sts get-caller-identity'"
}

case $ENV in
  stg)
  if [ "${ROLE}" = "SSO-Dev-Admin" ]; then
    role=arn:aws:iam::xxx:role/${ROLE}
    trustRelation=arn:aws:iam::xxx:saml-provider/KeyCloak
    createCredential

  else [ "${ROLE}" = "SSO-Dev-Develop" ];
    role=arn:aws:iam::xxx:role/${ROLE}
    trustRelation=arn:aws:iam::xxx:saml-provider/SSO-AWS-Kurly
    createCredential
  fi
  ;;

  prod)
  if [ "${ROLE}" = "SSO-Prod-Admin" ]; then
    role=arn:aws:iam::xxxx:role/${ROLE}
    trustRelation=arn:aws:iam::xxxx:saml-provider/Keycloak
    createCredential

  else [ "${ROLE}" = "SSO-Prod-Develop" ] || [ "${ROLE}" = "SSO-Prod-Develop-Approval" ];
    role=arn:aws:iam::xxxx:role/${ROLE}
    trustRelation=arn:aws:iam::xxxx:saml-provider/SSO-AWS-Kurly
    createCredential
  fi
  ;;

esac
