#!/bin/sh

private_registry=registry.redhat.io
#private_registry=registry.futuregen.cloud:5000

images=$(docker images | grep -i $private_registry | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    echo "= OC IMPORT IMAGE START ================="
    echo "image : $image"
    oc import-image  $image -n openshift --confirm
    echo "= OC IMPORT IMAGE END ==================="
    echo "================================================================================"
done
