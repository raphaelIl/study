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
    log "Upgrade chart ${NAME} failed, see detail log in '<cluster_dir>/.upgrade/upgrade-charts.log'"
    log
    exit 1
  fi
}

function check_chart_pkg() {
  log "Checking chart package"
  if [[ ! -f "$CHART_PATH" ]]; then
    log "Chart package $CHART_PATH does not exist."
    my_exit 1
  fi
}

function check_reupgrade() {
  log "Checking chart re-upgrade"
  if [[ -f ${WORK_DIR}/.upgrade/${NAME}/deploy ]]; then
    if [[ "$(cat ${WORK_DIR}/.upgrade/${NAME}/deploy)" == "fresh" ]]; then
      log "Chart ${NAME} is a new chart installed, upgrade skipped."
      my_exit 0
    elif [[ "$(cat ${WORK_DIR}/.upgrade/${NAME}/deploy)" == "upgrade" ]]; then
      log "Chart ${NAME} has upgraded."
      my_exit 0
    fi
  fi
}

function check_version() {
  log "Checking chart version"
  local old_chart_version=$(helm history --tls ${NAME} | tail -1 | cut -f4 | sed 's/.*-\(.*\)$/\1/')
  local new_chart_version=$(echo $CHART_PATH | sed 's/.*-\(.*\).tgz$/\1/')
  log "Old version: $old_chart_version"
  log "New version: $new_chart_version"
  if [[ "$old_chart_version" == "$new_chart_version" ]]; then
    log "Chart ${NAME} version no change, upgrade skipped."
    echo "old" > ${WORK_DIR}/.upgrade/${NAME}/deploy
    my_exit 0
  fi
}

function check_status() {
  log "Checking chart status"
  local chart_status=$(helm status ${NAME} --tls | grep '^STATUS:' | awk -F': ' '{print $2}')
  if [[ "$chart_status" != "DEPLOYED" ]]; then
    log "Chart status is $chart_status, cannot be upgrade. Fix the chart issue and rerun 'upgrade-chart' again."
    my_exit 1
  fi
}

function check_revision() {
  log "Checking chart revision"
  if [[ -f ${WORK_DIR}/.upgrade/${NAME}/revision-old.txt ]]; then
    log "Chart ${NAME} has upgraded."
    my_exit 0
  fi
}

function upgrade() {
  log "Upgrading chart $NAME"
  local revision=$(helm history --tls ${NAME} | tail -1 | cut -f1)
  echo $revision > ${WORK_DIR}/.upgrade/${NAME}/revision-old.txt
  helm get values --tls ${NAME} > ${WORK_DIR}/.upgrade/${NAME}/values-old.yaml
  cat > ${WORK_DIR}/.upgrade/${NAME}/values-override.yaml <<EOF
$OVERRIDE
EOF
  helm upgrade --tls ${UPGRADE_EXTRA_ARGS} --timeout=${TIMEOUT} --force -f ${WORK_DIR}/.upgrade/${NAME}/values-old.yaml -f ${WORK_DIR}/.upgrade/${NAME}/values-override.yaml ${NAME} ${CHART_PATH} >> $LOG_FILE 2>&1
  RC=$?
  echo "upgrade" > ${WORK_DIR}/.upgrade/${NAME}/deploy
  my_exit $RC
}

function install() {
  [[ "$NAME" == "calico" || "$NAME" == "nsx_t" ]] && my_exit $?
  log "Installing chart $NAME"
  helm install --tls ${INSTALL_EXTRA_ARGS} --timeout=${TIMEOUT} --name=${NAME} --namespace=${NAMESPACE} -f ${WORK_DIR}/.upgrade/${NAME}/values.yaml ${CHART_PATH} >> $LOG_FILE 2>&1
  RC=$?
  echo "fresh" > ${WORK_DIR}/.upgrade/${NAME}/deploy
  my_exit $RC
}

function run() {
  local chart_exist=$(helm list -a --tls | awk '{print $1}' | grep "^${NAME}$")
  if [[ "X$chart_exist" == "X" ]]; then
    check_chart_pkg
    install
  else
    check_chart_pkg
    check_reupgrade
    check_version
    check_status
    upgrade
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
    --path)
      shift
      CHART_PATH="$1"
      ;;
    --path=*)
      CHART_PATH="${1#*=}"
      ;;
    --override)
      shift
      OVERRIDE="$1"
      ;;
    --override=*)
      OVERRIDE="${1#*=}"
      ;;
    --namespace)
      shift
      NAMESPACE="$1"
      ;;
    --namespace=*)
      NAMESPACE="${1#*=}"
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
    --installExtraArgs)
      shift
      INSTALL_EXTRA_ARGS="$1"
      ;;
    --installExtraArgs=*)
      INSTALL_EXTRA_ARGS="${1#*=}"
      ;;
    --upgradeExtraArgs)
      shift
      UPGRADE_EXTRA_ARGS="$1"
      ;;
    --upgradeExtraArgs=*)
      UPGRADE_EXTRA_ARGS="${1#*=}"
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
CHART_PATH=${CHART_PATH:-}
OVERRIDE=${OVERRIDE:-}
NAMESPACE=${NAMESPACE:-kube-system}
TIMEOUT=${TIMEOUT:-600}
INSTALL_EXTRA_ARGS=${INSTALL_EXTRA_ARGS:-}
UPGRADE_EXTRA_ARGS=${UPGRADE_EXTRA_ARGS:-}
LOG_FILE=${WORK_DIR}/.upgrade/upgrade-charts.log
[[ -d ${WORK_DIR}/.upgrade ]] || mkdir ${WORK_DIR}/.upgrade

log "----------------------- START UPGRADING CHART ($NAME) ---------------------"
log "NAME: $NAME"
log "WORK_DIR: $WORK_DIR"
log "INSTALL_EXTRA_ARGS: $INSTALL_EXTRA_ARGS"
log "UPGRADE_EXTRA_ARGS: $UPGRADE_EXTRA_ARGS"
log "CHART_PATH: $CHART_PATH"
log "NAMESPACE: $NAMESPACE"
log "TIMEOUT: $TIMEOUT"
[[ "X$NAME" == "X" ]] && my_exit $?
[[ "X$CHART_PATH" == "X" ]] && my_exit $?
run
log

exit 0
