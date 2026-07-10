#!/usr/bin/env bash
# scripts/run-scan.sh
# Deploys the intentionally-broken sample workloads, waits briefly for them
# to fail, then runs K8sGPT against just that namespace.
set -euo pipefail

echo "Applying lab manifests..."
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/broken-deployment.yaml
kubectl apply -f manifests/crashloop-pod.yaml
kubectl apply -f manifests/missing-configmap-pod.yaml

echo "Waiting 30s for failures to surface..."
sleep 30

echo "Current state of the lab namespace:"
kubectl get pods -n k8sgpt-lab

echo ""
echo "Running K8sGPT analysis with AI explanation..."
k8sgpt analyze --explain --namespace k8sgpt-lab
