#!/usr/bin/env bash
#
# Dependencies:
#   brew install jq curl
#
# Setup:
#   chmod 700 ./this-shell
#
# Usage:
#   ./this-shell [kubernetes cluster name] [elasticsearch cluster name] [elasticsearch endpoint]

set -o errexit
set -o nounset
set -o pipefail

fail() {
  echo "ERROR: ${*}"
  exit 1
}

usage() {
  cat <<-EOM
Usage: ${0##*/} [kubernetes cluster name] [elasticsearch cluster name] [elasticsearch endpoint]
e.g. ${0##*/} dev elasticsearch-eros http://eros.dev.dailyhotel.in:9200
EOM
  exit 1
}

# Validate the number of command line arguments
if [[ $# -lt 3 ]]; then
  usage
fi

# Validate that this workstation has access to the required executables
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}")/../.." && pwd )"
KUBERNETES_CLUSTER=${1}
KUBECTL="${PROJECT_ROOT}/${KUBERNETES_CLUSTER}/bin/kubectl --kubeconfig=${PROJECT_ROOT}/${KUBERNETES_CLUSTER}/kubeconfig"
ELASTICSEARCH_CLUSTER=${2}
ELASTICSEARCH_CLUSTER_ENDPOINT=${3}


command -v jq >/dev/null || fail "jq is not installed!"
command -v curl >/dev/null || fail "curl is not installed!"

# Sets the cluster.routing.allocation.enable settings to "none".
# Prevents shards from being migrated from an upgrading Data Node to another active Data Node.
disable_shard_allocation() {
  echo "Disable shard allocation..."
  curl -X PUT "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/settings" \
      -H "Content-Type: application/json" \
      -d '{"persistent":{"cluster.routing.allocation.enable":"none"}}'
  echo ""
}

# Disable cluster processes as recommended by the Elasticsearch documentation
prep_for_update() {
  disable_shard_allocation

  echo "Stop non-essential indexing and perform a sync flush..."
  curl -X POST "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_flush/synced"
  echo ""
}

# sets the cluster.routing.allocation.enable to the default value ("all")
enable_shard_allocation() {
  echo ""
  curl -X PUT "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/settings" \
      -H "Content-Type: application/json" \
      -d '{"persistent":{"cluster.routing.allocation.enable":"all"}}'
  echo ""
}

# Checks cluster health in a loop waiting for unassigned to return to 0
wait_for_allocations() {
  echo "Checking shard allocations"
  while true; do
    unassigned=$(curl "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/health" 2>/dev/null \
                | jq -r '.unassigned_shards')
    if [[ "${unassigned}" == "0" ]]; then
      echo "All shards-reallocated"
      return 0
    else
      echo "Number of unassigned shards: ${unassigned}"
      sleep 3s
    fi
  done
}

# checks the cluster health endpoint and looks for a 'green' status response in a loop
# Usage:
#   wait_for_green [data nodes]
# Where:
#   [data nodes] is the number of replicas defined in the Data Node StatefulSet
wait_for_green() {
  data_nodes=${1}
  echo "Checking cluster status"
  # First, wait for the new data node to join the cluster, wait and loop
  while true; do
    nodes=$(curl "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/health" 2>/dev/null \
            | jq -r '.number_of_data_nodes')
    if [[ ${nodes} == "${data_nodes}" ]]; then
      # Now that the data node is back, we can re-enable shard allocations
      echo "Elasticsearch cluster status has stabilized"
      enable_shard_allocation

      # Wait for the shards to re-initialize
      wait_for_allocations
      break
    fi
    echo "Data nodes available: ${nodes}, waiting..."
    sleep 20s
  done

  # Now that the data node is joined, wait for its shards to complete initialization
  while true; do
    status=$(curl "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/health" 2>/dev/null \
            | jq -r '.status')
    if [[ "${status}" == "green" ]]; then
      echo "Cluster health is now ${status}, continuing upgrade...."
      disable_shard_allocation
      return 0
    fi
    echo "Cluster status: ${status}"
    sleep 5s
  done
}

# Update a Statefulset's image tag then upgrade one pod at a time, waiting for the cluster health to return to 'green' before proceeding to the next pod
# This function similar to kubectl rollout restart
restart_statefulset() {
  name=${1}

  echo "Restarting the ${name} Statefulset to Elasticsearch"

  # For a statefulset with 3 replicas, this will loop three times wth the 'ORDINAL' values 2, 1, and 0
  replicas=$(${KUBECTL} --namespace default get statefulset "${name}" -o jsonpath='{.spec.replicas}')
  max_ordinal=$(( ${replicas} - 1 ))
  for ordinal in $(seq "${max_ordinal}" 0); do
    current_pod="${name}-${ordinal}"
    echo "Restarting ${current_pod}"

    ${KUBECTL} --namespace default delete pod "${current_pod}"

    # Give some time for the es java process to terminate and the cluster state to turn 'yellow'
    sleep 3s

    # Now wait for the cluster health to return to 'green'
    wait_for_green "${replicas}"
  done
}

# Re-enable any services disabled prior to the upgrade
post_update_cleanup() {
  enable_shard_allocation
}

# The restart procedure
restart() {
  elasticsearch_cluster_name=${1}
  echo "Elasticsearch cluster name: ${elasticsearch_cluster_name}"

  prep_for_update

  restart_statefulset "${elasticsearch_cluster_name}-data"

  # Post update cleanup
  post_update_cleanup

  echo "Restart complete!"
}

# There is only one task, perform the update
restart "${ELASTICSEARCH_CLUSTER}"
