#!/usr/bin/env bash

# Licensed Materials - Property of IBM
# 5737-E67
# @ Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

# This script is used to get all image list

function log() {
  local datetime=`date +"%y-%m-%d %H:%M:%S"`
  local message=$1
  echo "[$datetime] ${message}" | tee -a ${LOG_FILE}
}

function _images_chart() {
  log "Get all chart images"
  local images=${SCRIPT_PATH}/images-chart.txt
  [[ ! -f $images ]] || > $images
  local tmpfile=$(mktemp ${SCRIPT_PATH}/temp.XXXXXX)
  local repository=
  local tag=
  for addon in $(ls /addon/*.tgz)
  do
    [[ -d ${SCRIPT_PATH}/chart ]] && rm -rf ${SCRIPT_PATH}/chart/* || mkdir ${SCRIPT_PATH}/chart
    pushd ${SCRIPT_PATH}/chart > /dev/null 2>&1
      cp $addon .
      tar -zxf *.tgz >> $LOG_FILE 2>&1
      line_nums=$(grep -n -E  "^[ \t]*repository:" ./*/values.yaml | cut -d: -f1) >> $LOG_FILE 2>&1
      for num in $line_nums
      do
        repository=$(sed -n "${num}p" ./*/values.yaml | cut -d: -f2 | sed 's/"//g' | sed 's/ //g')
        tag=$(sed -n "$((num + 1))p" ./*/values.yaml)
        if [[ "$tag" =~ "tag:" ]]; then
          tag=$(echo $tag | cut -d: -f2 | sed -e 's/"//g' -e "s/'//g" -e 's/ //g')
        else
          tag=
        fi
        [[ "X$repository" != "X" && "X$tag" != "X" ]] && image=${repository##*/}:$tag || continue
        echo $image >> $tmpfile
      done
    popd > /dev/null 2>&1
  done
  cat $tmpfile | sort -u > $images
  rm -rf $tmpfile
}

function _images_common {
  log "Get all common images"
  local images=${SCRIPT_PATH}/images-common.txt
  [[ ! -f $images ]] || > $images
  grep -E "^[a-z].*_image:" /installer/playbook/group_vars/all.yaml | cut -d/ -f2 | sed 's/"//g' >> $images
  echo icp-inception:${RELEASE_TAG}-ee >> $images
}

function list_images() {
  _images_chart
  _images_common
  mkdir -p $(dirname $IMAGE_LIST_FILE)
  if [[ -f ${SCRIPT_PATH}/images-common.txt && -f ${SCRIPT_PATH}/images-chart.txt ]]; then
    cat ${SCRIPT_PATH}/images-common.txt ${SCRIPT_PATH}/images-chart.txt | sort -u > $IMAGE_LIST_FILE
  fi
}

#----------------------------------- Main -------------------------------------#
while getopts :r: opt
do
  case "$opt" in
  r)
    RELEASE_TAG="${OPTARG}"
    ;;
  ?)
    exit 0
    ;;
  esac
done

RELEASE_TAG=${RELEASE_TAG:-latest}
# Init basic variables
SCRIPT_PATH=$(cd `dirname $0`; pwd)
LOG_DIR=/installer/cluster/logs/.detail
[[ -d $LOG_DIR ]] || mkdir $LOG_DIR
LOG_FILE=${LOG_DIR}/image-list.log.$(date +"%Y%m%d%H%M%S")
IMAGE_LIST_FILE=/installer/cluster/.misc/image-list.txt

# Start run
list_images
