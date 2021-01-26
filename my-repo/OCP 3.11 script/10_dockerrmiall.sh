#!/bin/sh

images=$(docker images | awk '{print $1":"$2}')

for image in $images; do
    echo "================================================================================"
    echo "= REMOVE ALL IMAGE START ================="
    echo "image : $image"
    docker rmi $image
    echo "= REMOVE ALL IMAGE END ==================="
    echo "================================================================================"
done
