#!/bin/sh

private_registry=registry.futuregen.cloud:5000
images=$(docker images | grep registry.redhat.io | grep -vi tag | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    tagimage="$private_registry/openshift/$(echo $image | cut -f 3 -d '/')"
    echo "= TAGGING START ================="
    echo "image : $image"
    echo "tagimage : $tagimage"
    docker tag $image $tagimage
    echo "= TAGGING END ==================="
    echo "================================================================================"
done
