#!/bin/sh
# master restart

echo -e "master-restart api---------------------------------"
ansible masters -m shell -a "/usr/local/bin/master-restart api"

echo -e "master-restart controllers-------------------------"
ansible masters -m shell -a "/usr/local/bin/master-restart controllers"

echo -e "node status----------------------------------------"
ansible all -m ping
