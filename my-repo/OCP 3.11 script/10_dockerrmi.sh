#!/bin/sh

private_registry=registry.redhat.io
#private_registry=registry.connect.redhat.com
#private_registry=registry.futuregen.cloud:5000
#private_registry=docker-registry-default.apps.pentalink.ocp/openshift

images=$(docker images | grep -i $private_registry | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    echo "= REMOVE IMAGE START ================="
    echo "image : $image"
    docker rmi $image
    echo "= REMOVE IMAGE END ==================="
    echo "================================================================================"
done
