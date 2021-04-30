#!/bin/sh
# oc login -u ocpadmin -p ocpadmin.! https://paasmaster.test.cloud:8443
# docker login -u ocpadmin -p $(oc whoami -t) docker-registry-default.paas.test.cloud

private_registry=docker-registry-default.paas.test.cloud/openshift

images=$(docker images | grep -i $private_registry | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    echo "= PUSH IMAGE START ================="
    echo "image : $image"
    docker push $image
    echo "= PUSH IMAGE END ==================="
    echo "================================================================================"
done
