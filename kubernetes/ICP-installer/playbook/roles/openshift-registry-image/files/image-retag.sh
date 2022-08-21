#!/usr/bin/env bash

# Licensed Materials - Property of IBM
# 5737-E67
# @ Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

# This script is used to retag all images

function log() {
  local datetime=`date +"%y-%m-%d %H:%M:%S"`
  local message=$1
  echo "[$datetime] ${message}" | tee -a ${LOG_FILE}
}

function tag_images() {
  log "Tag images"
  local TAG_ARCH=$1
  for IMAGE in $IMAGES; do
    if [[ "X$TAG_ARCH" != "X" ]]; then
      log "Docker tag: ${SOURCE_REPO}/${IMAGE//:/-$TAG_ARCH:} -> ${TARGET_REPO}/${IMAGE//:/-$TAG_ARCH:}"
      docker tag ${SOURCE_REPO}/${IMAGE//:/-$TAG_ARCH:} ${TARGET_REPO}/${IMAGE//:/-$TAG_ARCH:} 2>&1 | tee -a $LOG_FILE
      docker push ${TARGET_REPO}/${IMAGE//:/-$TAG_ARCH:} 2>&1 | tee -a $LOG_FILE
    else
      log "Docker tag: ${SOURCE_REPO}/${IMAGE//:/-$ARCH:} -> ${TARGET_REPO}/${IMAGE}"
      docker tag ${SOURCE_REPO}/${IMAGE//:/-$ARCH:} ${TARGET_REPO}/${IMAGE} 2>&1 | tee -a $LOG_FILE
      docker push ${TARGET_REPO}/${IMAGE} 2>&1 | tee -a $LOG_FILE
    fi
  done
}

function untag_images() {
  log "Untag images"
  local UNTAG_REPO=$1
  local UNTAG_ARCH=$2
  for IMAGE in $IMAGES; do
    if [[ "X$UNTAG_ARCH" != "X" ]]; then
      docker rmi ${UNTAG_REPO}/${IMAGE//:/-$UNTAG_ARCH:} 2>&1 | tee -a $LOG_FILE
    else
      docker rmi ${UNTAG_REPO}/${IMAGE} 2>&1 | tee -a $LOG_FILE
    fi
    # Handle icp-inception image
    if [[ "${IMAGE%:*}" == "icp-inception" ]]; then
      if docker inspect --type=image ${TARGET_REPO}/${IMAGE}; then
        docker tag ${TARGET_REPO}/${IMAGE} ${SOURCE_REPO}/${IMAGE//:/-$(uname -m | sed 's/x86_64/amd64/g'):}
      fi
    fi
  done
}

function run() {
  if [[ "X$OP_ARCH" == "X" ]]; then
    tag_images "$ARCH"
    tag_images
    untag_images "$SOURCE_REPO" "$ARCH"
  else
    tag_images "$OP_ARCH"
    untag_images "$SOURCE_REPO" "$OP_ARCH"
  fi
}

#----------------------------------- Main -------------------------------------#
while getopts :a:c:s:t: opt
do
  case "$opt" in
  a)
    OP_ARCH="${OPTARG}"
    ;;
  s)
    SOURCE_REPO="${OPTARG}"
    ;;
  t)
    TARGET_REPO="${OPTARG}"
    ;;
  ?)
    exit 0
    ;;
  esac
done

ARCH=$(uname -m | sed 's/x86_64/amd64/g')
OP_ARCH=${OP_ARCH:-}
SOURCE_REPO=${SOURCE_REPO:-ibmcom}
TARGET_REPO=${TARGET_REPO:-mycluster.icp:8500/ibmcom}

# Init basic variables
SCRIPT_PATH=$(cd `dirname $0`; pwd)
LOG_DIR=${SCRIPT_PATH}/logs
[[ -d $LOG_DIR ]] || mkdir $LOG_DIR
LOG_FILE=${LOG_DIR}/image-retag.log.$(date +"%Y%m%d%H%M%S")
IMAGE_LIST_FILE=${SCRIPT_PATH}/image-list.txt
IMAGES=$(cat ${IMAGE_LIST_FILE} | sort -u)

# Start run
run
