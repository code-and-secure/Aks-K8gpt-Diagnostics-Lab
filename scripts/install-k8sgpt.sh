#!/usr/bin/env bash
# scripts/install-k8sgpt.sh
# Installs the K8sGPT CLI and configures it to use OpenAI as the AI backend.
# Requires OPENAI_API_KEY to be set in your environment before running.
set -euo pipefail

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "Error: set OPENAI_API_KEY in your environment first, e.g.:"
  echo "  export OPENAI_API_KEY=sk-..."
  exit 1
fi

echo "Installing k8sgpt..."

if command -v brew >/dev/null 2>&1; then
  brew tap k8sgpt-ai/k8sgpt
  brew install k8sgpt
elif command -v kubectl >/dev/null 2>&1 && kubectl krew version >/dev/null 2>&1; then
  kubectl krew install k8sgpt
else
  echo "Homebrew/Krew not found — installing the latest Linux binary directly."
  ARCH="$(uname -m)"
  case "${ARCH}" in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
  esac
  LATEST_URL=$(curl -s https://api.github.com/repos/k8sgpt-ai/k8sgpt/releases/latest \
    | grep "browser_download_url.*linux_${ARCH}.tar.gz\"" \
    | cut -d '"' -f 4)
  curl -fsSL -o /tmp/k8sgpt.tar.gz "${LATEST_URL}"
  tar -xzf /tmp/k8sgpt.tar.gz -C /tmp
  sudo mv /tmp/k8sgpt /usr/local/bin/k8sgpt
fi

k8sgpt version

echo "Configuring OpenAI backend..."
k8sgpt auth add --backend openai --model gpt-4o-mini --password "${OPENAI_API_KEY}"
k8sgpt auth default --provider openai

echo "Done. Try: k8sgpt analyze --explain --namespace k8sgpt-lab"
