# Security Policy

This is a personal learning/practice repository, not a production project or
a maintained open-source library. There's no formal disclosure program or
bug bounty — but if you spot something that could bite someone following
along, please open an issue or a PR.

## Secrets used by this lab

Running through this lab means you'll be handling a few different
credentials. None of them belong in git, in a script, or pasted into a
public/shared place:

| Secret | Where it's used | Notes |
|---|---|---|
| Azure login (`az login`) | `deploy-cluster.sh` | Session-based; not stored in the repo. |
| `GROQ_API_KEY` | `install-k8sgpt.sh` | Export it in your shell only — never commit it, hardcode it in a script, or paste it into an issue/chat/screenshot. If it's ever been exposed that way, rotate it immediately at [console.groq.com/keys](https://console.groq.com/keys). |
| `kubeconfig` (`~/.kube/config`) | written by `az aks get-credentials` | Grants cluster access. Don't commit it or upload it anywhere. |
| GitHub Personal Access Token | `git push` auth | Scope it to `repo` only, and prefer a credential helper (`git config --global credential.helper store`/`cache`) over retyping it, but never commit it. |

## If a secret leaks

1. Rotate/revoke it immediately at the provider (Groq console, GitHub token
   settings, `az` re-login, etc.) — assume anything pasted into a chat,
   ticket, or screenshot is compromised the moment it's sent.
2. Check `git log` / GitHub's push history to confirm it was never actually
   committed. If it was, rotating is still required — removing it from
   history doesn't undo prior exposure.

## Cloud cost is a safety concern too

The AKS worker node is a real, billable VM the moment it's provisioned
(see the cost warning in [README.md](README.md)). Leaving it running is a
cost/availability risk, not a security one, but the same discipline
applies: always run `./scripts/cleanup.sh <resource-group-name>` when
you're done, and confirm the resource group is actually gone in the Azure
portal.

## Reporting an issue

Open a GitHub issue on this repo describing the concern. For anything
involving an already-exposed credential, rotate it first — don't wait for a
response before doing that part.
