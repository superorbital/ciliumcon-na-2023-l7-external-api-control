#!/bin/bash
set -eou pipefail

[ -x helm ] && echo "Please install helm before continuing" >&2 && exit 1

kubeconfig_file="$(mktemp)"
trap 'rm -f ${kubeconfig_file}' 0 2 3 15

cluster_name="${1:-kind}"
kind get kubeconfig --name "${cluster_name}" > "${kubeconfig_file}"

# Ensure cert-manager repo exists and is up-to-date before installing
helm repo add jetstack https://charts.jetstack.io \
  && helm repo update \
  && helm upgrade --kubeconfig "${kubeconfig_file}" --install --wait --create-namespace cert-mananger jetstack/cert-manager \
     --namespace cert-manager \
     --version 1.13.1 \
     --set "installCRDs=true"
