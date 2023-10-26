#!/bin/bash
set -eou pipefail

[ -x kind ] && echo "Please install kind before continuing, see README for instructions" >&2 && exit 1

cluster_name="${1:-kind}"
if kind get clusters | grep "${cluster_name}" > /dev/null; then
  kind get kubeconfig --name "${cluster_name}" > kind-cluster.kubeconfig
else
  echo "Could not get kubeconfig for cluster \"${cluster_name}\"" >&2 && exit 1
fi
