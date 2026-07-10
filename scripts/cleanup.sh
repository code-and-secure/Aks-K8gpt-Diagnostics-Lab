#!/usr/bin/env bash
# scripts/cleanup.sh
# Deletes the whole resource group so the AKS node stops billing, then
# removes the matching entries from the local kubeconfig so `kubectl`
# doesn't keep pointing at a cluster that no longer exists.
# The control plane is free, but the VM node is not — always clean up
# when you're done for the day.
set -euo pipefail

RESOURCE_GROUP="${1:-rg-aksk8sgpt-dev}"
CLUSTER_NAME="${2:-aks-aksk8sgpt}"

echo "This will delete resource group: ${RESOURCE_GROUP}"
read -p "Type the resource group name to confirm: " CONFIRM

if [[ "${CONFIRM}" != "${RESOURCE_GROUP}" ]]; then
  echo "Confirmation did not match. Aborting."
  exit 1
fi

az group delete --name "${RESOURCE_GROUP}" --yes --no-wait
echo "Deletion started for ${RESOURCE_GROUP} (running in background)."

echo "Cleaning up local kubeconfig entries for ${CLUSTER_NAME}..."
kubectl config delete-context "${CLUSTER_NAME}" 2>/dev/null || true
kubectl config delete-cluster "${CLUSTER_NAME}" 2>/dev/null || true
kubectl config delete-user "clusterUser_${RESOURCE_GROUP}_${CLUSTER_NAME}" 2>/dev/null || true
echo "kubeconfig cleaned up."
