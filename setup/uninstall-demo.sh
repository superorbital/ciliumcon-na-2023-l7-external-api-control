#!/bin/bash
set -eou pipefail

kubeconfig_file="$(mktemp)"
trap 'rm -f ${kubeconfig_file}' 0 2 3 15

cluster_name="${1:-kind}"
kind get kubeconfig --name "${cluster_name}" > "${kubeconfig_file}"

kubectl --kubeconfig "${kubeconfig_file}" delete -k kustomize/
