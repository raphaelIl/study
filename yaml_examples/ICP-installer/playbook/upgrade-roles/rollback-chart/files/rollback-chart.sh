#!/usr/bin/env bash

# Licensed Materials - Property of IBM
# 5737-E67
# @ Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

function log() {
  local datetime=`date +"%y-%m-%d %H:%M:%S"`
  local message=$1
  echo "[$datetime] ${message}" | tee -a ${LOG_FILE}
}

function my_exit() {
  [[ "$1" == "0" ]] && log && exit 0
  if [[ "$1" != "0" ]]; then
    log "Rollback chart ${NAME} failed, see detail log in '<cluster_dir>/.upgrade/upgrade-charts.log'"
    log
    exit 1
  fi
}

function rollback() {
  log "Rollbacking chart $NAME"
  helm rollback --tls ${ROLLBACK_EXTRA_ARGS} --timeout=${TIMEOUT} --force ${NAME} $(cat ${WORK_DIR}/.upgrade/${NAME}/revision-old.txt) >> $LOG_FILE 2>&1
  RC=$?
}

function delete() {
  log "Deleting chart $NAME"
  helm delete --purge --tls --timeout=${TIMEOUT} ${NAME} >> $LOG_FILE 2>&1
  RC=$?
}

function run() {
  local chart_exist=$(helm list -a --tls | awk '{print $1}' | grep "^${NAME}$")
  if [[ "X$chart_exist" != "X" ]]; then
    if [[ -f ${WORK_DIR}/.upgrade/${NAME}/deploy ]]; then
      if [[ "$(cat ${WORK_DIR}/.upgrade/${NAME}/deploy)" == "upgrade" ]]; then
        rollback
        log "Chart ${NAME} is rollbacked"
      elif [[ "$(cat ${WORK_DIR}/.upgrade/${NAME}/deploy)" == "fresh" ]]; then
        delete
        log "Chart ${NAME} is a fresh install, deleted"
      else
        log "Chart ${NAME} is not upgraded, skip rollback"
      fi
    else
      log "Nothing to do, chart ${NAME} has been rollbacked or don't need rollback."
    fi
    rm -rf ${WORK_DIR}/.upgrade/${NAME}
  else
    log "Chart ${NAME} does not exist, skip rollback."
  fi
}

while [ "$#" -gt "0" ]
do
  case "$1" in
    --name)
      shift
      NAME="$1"
      ;;
    --name=*)
      NAME="${1#*=}"
      ;;
    --timeout)
      shift
      TIMEOUT="$1"
      ;;
    --timeout=*)
      TIMEOUT="${1#*=}"
      ;;
    --workdir)
      shift
      WORK_DIR="$1"
      ;;
    --workdir=*)
      WORK_DIR="${1#*=}"
      ;;
    --rollbackExtraArgs)
      shift
      ROLLBACK_EXTRA_ARGS="$1"
      ;;
    --rollbackExtraArgs=*)
      ROLLBACK_EXTRA_ARGS="${1#*=}"
      ;;
    *) #default
      echo "Invalidate args."
      exit 1
      ;;
  esac
  shift
done

RC=0
WORK_DIR=${WORK_DIR:-/installer/cluster}
NAME=${NAME:-}
TIMEOUT=${TIMEOUT:-600}
ROLLBACK_EXTRA_ARGS=${ROLLBACK_EXTRA_ARGS:-}
LOG_FILE=${WORK_DIR}/.upgrade/rollback-charts.log
[[ -d ${WORK_DIR}/.upgrade ]] || mkdir ${WORK_DIR}/.upgrade

log "----------------------- START ROLLBACK CHART ($NAME) ---------------------"
log "NAME: $NAME"
log "WORK_DIR: $WORK_DIR"
log "TIMEOUT: $TIMEOUT"
log "ROLLBACK_EXTRA_ARGS: $ROLLBACK_EXTRA_ARGS"
[[ "X$NAME" == "X" ]] && my_exit $?
run
log

exit $RC
