#!/bin/bash
set -eou pipefail

[ -x helm ] && echo "Please install helm before continuing" >&2 && exit 1
[ -x cilium ] && echo "Please install the cilium CLI before continuing" >&2 && exit 1

kubeconfig_file="$(mktemp)"
trap 'rm -f ${kubeconfig_file}' 0 2 3 15

cluster_name="${1:-kind}"

# We need to export this variable because the cilium cli doesn't have a `--kubeconfig` flag...
export KUBECONFIG="${kubeconfig_file}"
kind get kubeconfig --name "${cluster_name}" > "${kubeconfig_file}"

# Ensure cilium repo exists and is up-to-date before installing
helm repo add cilium https://helm.cilium.io/ \
  && helm repo update \
  && helm upgrade --install cilium cilium/cilium \
     --namespace kube-system \
     --version 1.14.3 \
     --set "tls.secretsBackend=k8s"

cilium status --wait
