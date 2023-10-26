#!/bin/bash
set -eou pipefail

# Clean up cluster
cluster_name="${1:-kind}"
if kind get clusters | grep "${cluster_name}" > /dev/null; then
  kind delete cluster --name "${cluster_name}"
fi

# Clean up local registry
reg_name="kind-registry"
if docker inspect -f '{{.State.Running}}' "${reg_name}" &> /dev/null; then
  docker container stop "${reg_name}" > /dev/null
  docker container rm "${reg_name}" > /dev/null
fi
if docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}" &> /dev/null; then
  docker network rm kind > /dev/null
fi