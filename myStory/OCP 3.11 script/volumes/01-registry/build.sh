oc create -f registry-pv.yaml
oc create -f registry-pvc.yaml -n default
oc volumes dc docker-registry --add --name=registry-storage -t pvc -m /registry --claim-name=registry-claim --overwrite -n default