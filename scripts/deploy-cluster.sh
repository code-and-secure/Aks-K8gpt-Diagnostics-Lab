#!/usr/bin/env bash
# scripts/deploy-cluster.sh
# Deploys the AKS cluster defined in infra/main.bicep.
set -euo pipefail

LOCATION="${1:-koreacentral}"

echo "Deploying AKS cluster to region: ${LOCATION}"

az deployment sub create \
  --name aks-k8sgpt-lab-deploy \
  --location "${LOCATION}" \
  --template-file infra/main.bicep \
  --parameters location="${LOCATION}"

echo ""
echo "Deployment complete. Fetching kubeconfig..."

RG=$(az deployment sub show --name aks-k8sgpt-lab-deploy --query properties.outputs.resourceGroup.value -o tsv)
CLUSTER=$(az deployment sub show --name aks-k8sgpt-lab-deploy --query properties.outputs.clusterName.value -o tsv)

az aks get-credentials --resource-group "${RG}" --name "${CLUSTER}" --overwrite-existing

echo "kubectl is now pointed at ${CLUSTER}. Try: kubectl get nodes"
