#!/bin/bash

if ! ls cluster/config.yaml cluster/hosts &>/dev/null; then
    echo
    echo "Can't find config.yaml or hosts file"
    echo "Please correct your command and run again"
    echo
    exit 1
fi

STATUS=0
ARG=$1
LOG_DIR=/installer/cluster/logs
MYPIPE=/tmp/mypipe
cd $(dirname $0)

function check_license () {
    if [ "$LICENSE" = "accept" ]; then
        :
    elif [ "$LICENSE" = "view" ]; then
        unzip -qq "$(ls cfc-files/license/*.zip | head -1)"
        lang=${LANG%%.*}
        if [[ "$lang" != "zh_TW" ]]; then
            lang=${lang%%_*}
        fi
        [[ ! -f UTF8/LA_${lang} ]] && lang="en"
        cat UTF8/LA_${lang}
        exit 0
    else
        echo "You should either view or accept the license"
        echo "View License by adding an environment variable to docker run command: -e LICENSE=view"
        echo "Accept License by adding an environment variable to docker run command: -e LICENSE=accept"
        exit 1
    fi
}

function runcmd () {
    local cmdline="$1"
    [[ ! -d $LOG_DIR ]] && mkdir $LOG_DIR
    [[ ! -p $MYPIPE ]] && mkfifo $MYPIPE
    cat $MYPIPE | tee -a ${LOG_DIR}/${ARG}.log.$(date +"%Y%m%d%H%M%S") &
    unbuffer $cmdline > $MYPIPE 2>&1
}

function set_permission() {
    chmod 400 /installer/cluster/ssh_key &>/dev/null
}

function get_hosts() {
    local nodes=
    while getopts ":l:" option; do
        case $option in
            l)
                nodes=$OPTARG
                ;;
        esac
    done
    if ! [[ "$nodes" =~ (master|worker|proxy|management|va|metering|monitoring|logging|hostgroup) ]]; then
        echo ${nodes//,/ }
    fi
}

check_license
set_permission

case $ARG in
    check)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/all-check.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    install)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/install.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    uninstall)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/uninstall.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        if [[ $STATUS == 0 ]]; then
            for host in $(get_hosts ${@:2}); do
                sed -i "/^${host}$/d" cluster/hosts
                sed -i "/^${host}[ \t]/d" cluster/hosts
            done
        fi
        echo
        ;;
    proxy)
        for host in $(get_hosts ${@:2}); do
            if ! crudini --get cluster/hosts proxy | grep -qw $host; then
                crudini --set cluster/hosts proxy $host
            fi
        done
        cmd="ansible-playbook -e @cluster/config.yaml playbook/proxy.yaml -l proxy ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    management)
        for host in $(get_hosts ${@:2}); do
            if ! crudini --get cluster/hosts management | grep -qw $host; then
                crudini --set cluster/hosts management $host
            fi
        done
        cmd="ansible-playbook -e @cluster/config.yaml playbook/management.yaml -l management ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    worker)
        for host in $(get_hosts ${@:2}); do
            if ! crudini --get cluster/hosts worker | grep -qw $host; then
                crudini --set cluster/hosts worker $host
            fi
        done
        cmd="ansible-playbook -e @cluster/config.yaml playbook/worker.yaml -l worker ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    va)
        for host in $(get_hosts ${@:2}); do
            if ! crudini --get cluster/hosts va | grep -qw $host; then
                crudini --set cluster/hosts va $host
            fi
        done
        cmd="ansible-playbook -e @cluster/config.yaml playbook/va.yaml -l va ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    hostgroup)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/hostgroup.yaml -l hostgroup-* ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    addon)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/addon.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    install-docker)
        cmd="ansible-playbook -e @cluster/config.yaml -e container_runtime=docker playbook/install-runtime-engine.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    install-containerd)
        cmd="ansible-playbook -e @cluster/config.yaml -e container_runtime=containerd playbook/install-runtime-engine.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    uninstall-docker)
        cmd="ansible-playbook -e @cluster/config.yaml -e container_runtime=docker playbook/uninstall-runtime-engine.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    uninstall-containerd)
        cmd="ansible-playbook -e @cluster/config.yaml -e container_runtime=containerd playbook/uninstall-runtime-engine.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    upgrade-prepare)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/upgrade-prepare.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    upgrade-k8s)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/upgrade-k8s.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    upgrade-chart)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/upgrade-chart.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    upgrade-worker)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/upgrade-worker.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    upgrade-docker)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/upgrade-docker.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    rollback-k8s)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/rollback-k8s.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    rollback-chart)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/rollback-chart.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    rollback-worker)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/rollback-worker.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    rollback-docker)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/rollback-docker.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    patch)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/patch.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    unpatch)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/unpatch.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    install-on-openshift)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/install-on-openshift.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    uninstall-on-openshift)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/uninstall-on-openshift.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    add-arch)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/add-arch.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    archive-addon)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/archive-addon.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    replace-certificates)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/certificate.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    healthcheck)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/health-check.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    env-isolation)
        cmd="ansible-playbook -e @cluster/config.yaml playbook/environment-isolation.yaml ${@:2}"
        runcmd "$cmd"
        STATUS=$?
        echo
        ;;
    *)
        ${@}
esac

exit $STATUS
