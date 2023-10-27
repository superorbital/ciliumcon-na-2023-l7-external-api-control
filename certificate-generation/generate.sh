#!/bin/bash
set -eou pipefail

CA_CERT_BUNDLE=/etc/ssl/certs/ca-certificates.crt
MODIFIED_CA_CERT_BUNDLE=ca-certificates-modified.crt
INSPECTION_CA_NAME=inspection-ca
SAN_INFO="subjectAltName=DNS:github.com"

# Ensure we're using the latest CA certificates.
update-ca-certificates

# Wait for the self-signed CA certificate to provision.
kubectl wait --for=condition=READY certificate -n "${NAMESPACE}" so-selfsigned-ca-root-certificate

# Move to /tmp for the rest of the steps in script
cd /tmp

# Get our self-signed CA certificate.
kubectl get secret -n "${NAMESPACE}" so-tls-inspection-ca-root-certificate -o jsonpath='{.data.ca\.crt}' | base64 -d > "${INSPECTION_CA_NAME}".pem
kubectl get secret -n "${NAMESPACE}" so-tls-inspection-ca-root-certificate -o jsonpath='{.data.tls\.key}' | base64 -d > "${INSPECTION_CA_NAME}".key

# Add our CA certificate to the CA cert bundle on the system.
cp "${CA_CERT_BUNDLE}" "${MODIFIED_CA_CERT_BUNDLE}"
cat "${INSPECTION_CA_NAME}".pem >> "${MODIFIED_CA_CERT_BUNDLE}"

# Provide to Cilium the modified cert bundle as set of CAs that it should trust 
# when originating the secondary TLS connections.
kubectl delete secret tls-originating --ignore-not-found=true
kubectl create secret generic --from-file=ca.crt="${MODIFIED_CA_CERT_BUNDLE}" tls-originating

# Create the TLS certificates with a CN that matches the DNS of the 
# destination service to be intercepted for inspection.
openssl genrsa \
  -out internal.key 2048
openssl req \
  -new \
  -key internal.key \
  -out internal.csr \
  -config /x509-cert.conf \
  -addext "${SAN_INFO}"
openssl x509 \
  -req \
  -days 365 \
  -in internal.csr \
  -CA "${INSPECTION_CA_NAME}".pem \
  -CAkey "${INSPECTION_CA_NAME}".key \
  -CAcreateserial \
  -out internal.crt \
  -sha256 \
  -extfile <(printf %s "${SAN_INFO}")

# Deploy the certificates to the cluster
kubectl create secret tls -n "${NAMESPACE}" tls-terminating --cert internal.crt --key internal.key --dry-run=client -oyaml | kubectl apply -f -
