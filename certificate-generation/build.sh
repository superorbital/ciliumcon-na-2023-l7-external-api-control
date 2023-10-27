#!/bin/bash
set -eou pipefail

REGISTRY=${REGISTRY:-"localhost:5001"}
IMAGE=${VERSION:-"certificate-generation"}
TAG=${TAG:-"latest"}

CONTAINER_NAME="${REGISTRY}/${IMAGE}:${TAG}"

docker build -t "${CONTAINER_NAME}" .
docker push "${CONTAINER_NAME}"
