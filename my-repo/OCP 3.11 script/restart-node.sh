#!/bin/sh
# nodes restart

echo -e "all nodes restart---------------------------------------"
ansible nodes -m shell -a "systemctl restart atomic-openshift-node"

echo -e "node status----------------------------------------"
ansible all -m ping
