#!/bin/sh

private_registry=registry.test.cloud:5000

images=$(docker images | grep registry.redhat.io | grep -vi tag | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    tag=$(echo $image | cut -f 3 -d '/' | cut -f 2 -d ':')
    if [ $tag == "latest" ]
    then
      tag=$tag
    else
      tag="v3.11.104"
    fi
    tagimage="$private_registry/$(echo $image | cut -f 2,3 -d '/' | cut -f 1 -d ':'):$tag"
    echo "= TAGGING START ================="
    echo "image : $image"
    echo "tagimage : $tagimage"
    docker tag $image $tagimage
    echo "= TAGGING END ==================="
    echo "================================================================================"
done

docker tag registry.redhat.io/rhel7/etcd:3.2.22 $private_registry/rhel7/etcd:3.2.22
