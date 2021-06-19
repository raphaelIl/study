#!/usr/bin/env bash
ELAPSED_TIME=$1

if [ -z "${ELAPSED_TIME}" ]; then
  echo "plz input compare_time: "
  echo "e.g. ${0##*/} 100000"
  exit 1
fi

ALLUSER=$(aws iam list-users | jq -r '.Users[].UserName')
NOW=$(date "+%s")

for User in $ALLUSER
do
  # date: extra operand ‘+%s’
  # 아 유저 하나에 키 하나만 있는게 아니지...
  accesskeyids=$(aws iam list-access-keys --user-name "$User" | jq -r '.AccessKeyMetadata[].AccessKeyId')
  target_times=$(aws iam list-access-keys --user-name "$User" | jq -r '.AccessKeyMetadata[].CreateDate')
  target_time=$(date -d "$target_times" '+%s')
#  result_time=$(expr "$NOW" - "$target_time")
  let result_time="$NOW"-"$target_time"
  if [[ $accesskeyids =~ AKIA* ]] && (("$result_time" > "$ELAPSED_TIME")) ; then
#    echo -e "find_access_key $User: $accesskeyids"
    for select_user in $User
    do
      aws iam list-access-keys --user-name "$select_user"
      username=$(aws iam list-access-keys --user-name "$select_user" | jq -r '.AccessKeyMetadata[].UserName')
      accesskeyid=$(aws iam list-access-keys --user-name "$select_user" | jq -r '.AccessKeyMetadata[].AccessKeyId')
      createdate=$(aws iam list-access-keys --user-name "$select_user" | jq -r '.AccessKeyMetadata[].CreateDate')
      curl -s -d "payload={\"username\": \"success\",\"text\":\"username: $username, accesskeyid: $accesskeyid, createdate: $createdate\"}" $SLACK_WEBHOOK
    done
  else
    curl -s -d "payload={\"username\": \"fail\",\"text\":\"username: $User does not meet the conditions.\"}" $SLACK_WEBHOOK
  fi
done
