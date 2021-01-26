#!/bin/sh
# oc login -u ocpadmin -p ocpadmin.! https://paasmaster.test.cloud:8443
# docker login -u ocpadmin -p $(oc whoami -t) registry.test.cloud:5000

private_registry=registry.test.cloud:5000

images=$(docker images | grep -i $private_registry | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    echo "= PUSH IMAGE START ================="
    echo "image : $image"
    docker push $image
    echo "= PUSH IMAGE END ==================="
    echo "================================================================================"
done
