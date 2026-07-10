# aks-k8sgpt-diagnostics-lab

Practice project pairing Infrastructure-as-Code (Bicep, from the earlier
project) with an AI-powered Kubernetes diagnostic tool. You'll provision a
minimal AKS cluster, deploy a few intentionally broken workloads, then use
[K8sGPT](https://k8sgpt.ai/docs/getting-started/installation) with an OpenAI
backend to get plain-English root-cause explanations for each failure.

## ⚠️ Cost warning — read this first

Unlike the free-tier Bicep project, **this one is not free**:

- The AKS **control plane** uses the `Free` SKU tier — no charge, no SLA.
- The **worker node** is a real VM (`Standard_B2s`, ~$0.02–0.04/hour
  depending on region) and **you pay for it as long as it exists**, even
  if it's just sitting idle overnight.
- OpenAI API calls for `k8sgpt analyze --explain` cost a small amount per
  call (new accounts get some free credit — check your OpenAI usage page).

**Run `scripts/cleanup.sh` every time you're done for the session.** Don't
leave the cluster running between practice sessions.

## Project structure

```
aks-k8sgpt-lab/
├── infra/
│   ├── main.bicep              # subscription-scoped orchestrator
│   └── modules/
│       └── aks.bicep           # single-node, Free-tier AKS cluster
├── manifests/
│   ├── namespace.yaml
│   ├── broken-deployment.yaml  # bad image tag
│   ├── crashloop-pod.yaml      # container exits immediately
│   └── missing-configmap-pod.yaml  # references a ConfigMap that doesn't exist
└── scripts/
    ├── deploy-cluster.sh       # az deployment sub create + get-credentials
    ├── install-k8sgpt.sh       # installs K8sGPT CLI, configures OpenAI backend
    ├── run-scan.sh             # applies broken manifests, runs k8sgpt analyze
    └── cleanup.sh              # deletes the resource group (stops billing)
```

## Prerequisites

- Azure CLI, logged in (`az login`), Bicep installed (`az bicep install`)
- `kubectl` installed
- An OpenAI account with an API key (openai.com → API keys)
- Homebrew (recommended) or `kubectl krew`, for installing K8sGPT — see the
  [K8sGPT installation options](https://k8sgpt.ai/docs/getting-started/installation)
  for alternatives on Linux/Windows if you don't use Homebrew

## Step-by-step

```bash
chmod +x scripts/*.sh

# 1. Provision the cluster (~5-10 min)
./scripts/deploy-cluster.sh eastus

# 2. Install and configure K8sGPT
export OPENAI_API_KEY=sk-...
./scripts/install-k8sgpt.sh

# 3. Deploy broken workloads and scan them
./scripts/run-scan.sh

# 4. When you're done for the day
./scripts/cleanup.sh rg-aksk8sgpt-dev
```

`k8sgpt analyze --explain` will walk each failing resource and produce
something like: *"the deployment's container image tag doesn't exist in
the registry — check the tag name and confirm it's been pushed."* Compare
that explanation against what you already know is wrong in each manifest —
that comparison is the actual learning exercise.

## Suggested learning path

1. **Read the raw failures first.** Before running K8sGPT, use
   `kubectl describe pod <name> -n k8sgpt-lab` and try to diagnose each
   issue yourself. Then compare your read against K8sGPT's explanation.
2. **Break something new.** Write a 4th broken manifest — a resource
   request higher than the node can schedule, a readiness probe pointing
   at the wrong port, a Service with a mismatched selector — and see if
   K8sGPT catches it.
3. **Try filters.** `k8sgpt analyze --filter Pod` vs `--filter Deployment`
   vs no filter, to see how scope changes results.
4. **Move to the Operator.** Once comfortable with the CLI, install the
   [K8sGPT Operator](https://docs.k8sgpt.ai/getting-started/in-cluster-operator/)
   via Helm for continuous in-cluster monitoring instead of ad-hoc scans:
   ```bash
   helm repo add k8sgpt https://charts.k8sgpt.ai/
   helm repo update
   helm install release k8sgpt/k8sgpt-operator -n k8sgpt-operator-system --create-namespace
   ```
5. **Wire it into CI.** Add a GitHub Actions job that deploys to a
   short-lived cluster, runs `k8sgpt analyze`, and fails the build if any
   `error` severity issues are found — a taste of policy-as-code.
6. **Swap backends.** Try K8sGPT's local/offline model option and compare
   explanation quality and latency against OpenAI.

## Cleanup checklist

- [ ] `./scripts/cleanup.sh <resource-group-name>`
- [ ] Confirm in the Azure portal that the resource group is gone
- [ ] Revoke or rotate the OpenAI API key if this was a throwaway/shared key
