#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env if present
if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

echo "[bootstrap-prebrew] Starting pre-brew bootstrap..."

# Create dev directories early
"$ROOT_DIR/scripts/dirs.sh"

# Configure git identity if provided
if command -v git >/dev/null 2>&1; then
  if [ -n "${GIT_USER_NAME:-}" ]; then
    git config --global user.name "$GIT_USER_NAME"
  fi
  if [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
  if [ "${GIT_COMMIT_SIGN:-false}" = "true" ] && [ -n "${GIT_SIGNING_KEY:-}" ]; then
    git config --global commit.gpgsign true
    git config --global user.signingkey "$GIT_SIGNING_KEY"
  fi
  # Sensible git defaults (pre-stow)
  git config --global init.defaultBranch main || true
  git config --global fetch.prune true || true
  git config --global pull.ff only || true
  git config --global rebase.autoStash true || true
  git config --global merge.conflictstyle zdiff3 || true
  git config --global push.default simple || true
  git config --global push.autoSetupRemote true || true
  git config --global rerere.enabled true || true
  git config --global core.excludesfile "$HOME/.gitignore_global" || true
  git config --global credential.helper osxkeychain || true

  # Prefer SSH-based commit signing if SSH key exists
  if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    git config --global gpg.format ssh || true
    git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub" || true
    git config --global commit.gpgsign true || true
  fi
else
  echo "[bootstrap-prebrew] git not found in PATH; skipping git config."
fi

# Ensure a curlrc is present and proxy variables are honored
mkdir -p "$HOME"
if [ ! -f "$HOME/.curlrc" ]; then
  echo "--fail-with-body\n--show-error\n--location\n--retry 3\n--retry-delay 1\n--progress-bar" > "$HOME/.curlrc"
fi

# Optionally add proxies to .curlrc if provided
if [ -n "${HTTP_PROXY:-}" ] || [ -n "${HTTPS_PROXY:-}" ]; then
  {
    [ -n "${HTTP_PROXY:-}" ] && echo "proxy = $HTTP_PROXY"
    [ -n "${HTTPS_PROXY:-}" ] && echo "proxy = $HTTPS_PROXY"
  } >> "$HOME/.curlrc"
fi

echo "[bootstrap-prebrew] Done. You can now run: make brew-core"
