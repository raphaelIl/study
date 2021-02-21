#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

usage() {
  cat <<-EOM
Usage: ${0##*/} [kubernetes cluster name]
e.g. ${0##*/} (dev or endgame)
EOM
  exit 1
}

if [[ $# != 1 ]]; then
  usage
fi

echo -n "Are you really run? (yes or no): "
read -r CONFIRM

if [ ! "${CONFIRM}" == "yes" ]; then
  echo "Exit..."
  exit 1
fi

REPOSITORY_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}")/../.." && pwd )"
KUBERNETES_CLUSTER=${1}
KUBECTL="${REPOSITORY_ROOT}/${KUBERNETES_CLUSTER}/bin/kubectl --kubeconfig=${REPOSITORY_ROOT}/${KUBERNETES_CLUSTER}/kubeconfig"

dev_target_services=(
mobileapi
newdelhi-api
newdelhi-external-api
newdelhi-intranet
newdelhi-consumer
openapi
)

endgame_target_services=(
mobileapi
mobileapi-mockingjay
newdelhi-api
newdelhi-api-mockingjay
newdelhi-external-api
newdelhi-external-api-mockingjay
newdelhi-intranet
newdelhi-consumer
newdelhi-consumer-mockingjay
openapi
openapi-mockingjay
)

if [ "${KUBERNETES_CLUSTER}" = "dev" ]; then
  len=${#dev_target_services[*]}
  for ((i=0; i<len; i++)); do
    echo "${dev_target_services[$i]}"
    ${KUBECTL} rollout restart deployment "${dev_target_services[$i]}"
  done
fi

if [ "${KUBERNETES_CLUSTER}" = "endgame" ]; then
  len=${#endgame_target_services[*]}
  for ((i=0; i<len; i++)); do
    echo "${endgame_target_services[$i]}"

    ${KUBECTL} patch deployment "${endgame_target_services[$i]}" -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"kubectl.kubernetes.io/restartedAt\":\"$(date +'%Y-%m-%dT%H:%M:%S+09:00')\"}}}}}"
  done
fi

echo "Done..."
