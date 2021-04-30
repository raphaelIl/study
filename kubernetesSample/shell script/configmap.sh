#!/bin/bash

kubectl get cm -n kube-system | nl
kubectl get cm -n kube-system | nl > configmap_list
COUNT=$(kubectl get cm -n kube-system | wc -l)

for ((a=2;a<=$COUNT;a++))
do
    NAME=$(cat configmap_list | awk '{print $2'} | sed -n ${a}p)
    echo "======================================"
    echo "Here $NAME"
    echo "======================================"
    kubectl get cm -n kube-system $NAME -o yaml > $NAME.yaml
done

