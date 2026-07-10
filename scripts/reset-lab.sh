#!/usr/bin/env bash
# scripts/reset-lab.sh
# Removes just the k8sgpt-lab namespace (and everything in it) without
# touching the AKS cluster or the Azure resource group. Use this to reset
# between scan runs, e.g. after editing a manifest, without waiting through
# a full deploy/cleanup cycle.
set -euo pipefail

echo "Deleting namespace k8sgpt-lab (and all workloads in it)..."
kubectl delete namespace k8sgpt-lab --ignore-not-found

echo "Done. Re-run ./scripts/run-scan.sh to redeploy the broken workloads."
