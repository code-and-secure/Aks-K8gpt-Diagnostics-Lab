#!/usr/bin/env bash
# scripts/install-k8sgpt.sh
# Installs the K8sGPT CLI and configures it to use Groq (free tier, OpenAI-
# compatible API) as the AI backend.
# Requires GROQ_API_KEY to be set in your environment before running.
set -euo pipefail

if [[ -z "${GROQ_API_KEY:-}" ]]; then
  echo "Error: set GROQ_API_KEY in your environment first, e.g.:"
  echo "  export GROQ_API_KEY=gsk_..."
  echo "Get a free key at https://console.groq.com/keys"
  exit 1
fi

echo "Installing k8sgpt..."

if command -v brew >/dev/null 2>&1; then
  brew tap k8sgpt-ai/k8sgpt
  brew install k8sgpt
elif command -v kubectl >/dev/null 2>&1 && kubectl krew version >/dev/null 2>&1; then
  kubectl krew install k8sgpt
elif [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
  echo "Homebrew/Krew not found — installing the Windows binary directly (Git Bash detected)."
  INSTALL_DIR="${HOME}/bin"
  mkdir -p "${INSTALL_DIR}"
  curl -fsSL -o /tmp/k8sgpt.zip \
    https://github.com/k8sgpt-ai/k8sgpt/releases/latest/download/k8sgpt_Windows_x86_64.zip
  unzip -o /tmp/k8sgpt.zip -d /tmp
  mv /tmp/k8sgpt.exe "${INSTALL_DIR}/k8sgpt.exe"
  case ":${PATH}:" in
    *":${INSTALL_DIR}:"*) ;;
    *) echo "Add ${INSTALL_DIR} to your PATH (e.g. in ~/.bashrc): export PATH=\"${INSTALL_DIR}:\$PATH\"" ;;
  esac
  export PATH="${INSTALL_DIR}:${PATH}"
else
  echo "Homebrew/Krew not found — installing the latest Linux binary directly."
  ARCH="$(uname -m)"
  case "${ARCH}" in
    aarch64) ARCH="arm64" ;;
  esac
  curl -fsSL -o /tmp/k8sgpt.tar.gz \
    "https://github.com/k8sgpt-ai/k8sgpt/releases/latest/download/k8sgpt_Linux_${ARCH}.tar.gz"
  tar -xzf /tmp/k8sgpt.tar.gz -C /tmp
  sudo mv /tmp/k8sgpt /usr/local/bin/k8sgpt
fi

k8sgpt version

echo "Configuring Groq backend (via the OpenAI-compatible 'localai' provider)..."
k8sgpt auth add --backend localai --model llama-3.3-70b-versatile \
  --baseurl https://api.groq.com/openai/v1 --password "${GROQ_API_KEY}"
k8sgpt auth default --provider localai

echo "Done. Try: k8sgpt analyze --explain --namespace k8sgpt-lab"
