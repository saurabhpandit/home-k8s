#!/usr/bin/env bash

set -eou pipefail

DEFAULT_CLUSTER="production"
DEFUALT_GITHUB_REPO="home-k8s"
DEFAULT_GITHUB_USER="saurabhpandit"
DEFAULT_GITHUB_BRANCH="main"

export CLUSTER="${CLUSTER:-$DEFAULT_CLUSTER}"
export GITHUB_REPO="${GITHUB_REPO:-$DEFUALT_GITHUB_REPO}"
export GITHUB_USER="${GITHUB_USER:-$DEFAULT_GITHUB_USER}"
export GITHUB_BRANCH="${GITHUB_BRANCH:-$DEFAULT_GITHUB_BRANCH}"

export GITHUB_TOKEN="${GITHUB_TOKEN}"

flux >/dev/null || \
  ( echo "flux needs to be installed - https://toolkit.fluxcd.io/get-started/#install-the-toolkit-cli" && exit 1 )

# Check the cluster meets the fluxv2 prerequisites
flux check --pre || \
  ( echo "Prerequisites were not satisfied" && exit 1 )

echo "Applying cluster: ${CLUSTER}"
flux bootstrap github \
  --owner="${GITHUB_USER}" \
  --repository="${GITHUB_REPO}" \
  --path=k8s/clusters/"${CLUSTER}" \
  --branch="${GITHUB_BRANCH}" \
  --network-policy=false \
  --personal=true \
  --private=false
