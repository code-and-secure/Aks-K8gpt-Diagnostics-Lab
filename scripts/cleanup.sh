#!/usr/bin/env bash
# scripts/cleanup.sh
# Deletes the whole resource group so the AKS node stops billing.
# The control plane is free, but the VM node is not — always clean up
# when you're done for the day.
set -euo pipefail

RESOURCE_GROUP="${1:-rg-aksk8sgpt-dev}"

echo "This will delete resource group: ${RESOURCE_GROUP}"
read -p "Type the resource group name to confirm: " CONFIRM

if [[ "${CONFIRM}" != "${RESOURCE_GROUP}" ]]; then
  echo "Confirmation did not match. Aborting."
  exit 1
fi

az group delete --name "${RESOURCE_GROUP}" --yes --no-wait
echo "Deletion started for ${RESOURCE_GROUP} (running in background)."
