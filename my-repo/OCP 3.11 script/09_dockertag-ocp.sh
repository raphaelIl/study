#!/bin/sh

private_registry=docker-registry-default.apps.test.cloud

images=$(docker images | grep registry.redhat.cloud:5000 | grep -vi tag | awk '{print $1":"$2}')

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
