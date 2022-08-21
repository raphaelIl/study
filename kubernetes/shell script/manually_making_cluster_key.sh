#!/bin/bash

# This script is used to distribute cert-key (kubernetes version 1.13)

USER=root
CONTROL_PLANE_IPS="10.0.0.78 10.0.0.79"
for host in ${CONTROL_PLANE_IPS}; do
    ssh $host mkdir -p /etc/kubernetes/pki/etcd
    scp /etc/kubernetes/pki/ca.crt "${USER}"@$host:/etc/kubernetes/pki/ca.crt
    scp /etc/kubernetes/pki/ca.key "${USER}"@$host:/etc/kubernetes/pki/ca.key
    scp /etc/kubernetes/pki/sa.key "${USER}"@$host:/etc/kubernetes/pki/sa.key
    scp /etc/kubernetes/pki/sa.pub "${USER}"@$host:/etc/kubernetes/pki/sa.pub
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:/etc/kubernetes/pki/front-proxy-ca.crt
    scp /etc/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:/etc/kubernetes/pki/front-proxy-ca.key
    scp /etc/kubernetes/pki/etcd/ca.crt "${USER}"@$host:/etc/kubernetes/pki/etcd/ca.crt
    scp /etc/kubernetes/pki/etcd/ca.key "${USER}"@$host:/etc/kubernetes/pki/etcd/ca.key
    scp /etc/kubernetes/admin.conf "${USER}"@$host:/etc/kubernetes/admin.conf
done
