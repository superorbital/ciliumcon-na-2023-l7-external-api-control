#!/bin/bash
set -eou pipefail

kubeconfig_file="$(mktemp)"
trap 'rm -f ${kubeconfig_file}' 0 2 3 15

cluster_name="${1:-kind}"
kind get kubeconfig --name "${cluster_name}" > "${kubeconfig_file}"

# TODO: fix this kludge for kustomize not supporting generateName... must use
# a static name for the job and instead ensure the job doesn't exist before re-creating
kubectl --kubeconfig "${kubeconfig_file}" delete job -n students certificate-generation --ignore-not-found=true

kubectl --kubeconfig "${kubeconfig_file}" apply -k kustomize/
