#!/usr/bin/env bash
set -euo pipefail

EMAIL="${GIT_USER_EMAIL:-}"
[ -f "$(dirname "$0")/../.env" ] && source "$(dirname "$0")/../.env" || true

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$KEY_FILE" ]; then
  if [ -z "$EMAIL" ]; then
    read -r -p "Email for SSH key comment: " EMAIL
  fi
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
else
  echo "[ssh] Key already exists: $KEY_FILE"
fi

# macOS keychain and agent
if [[ "$OSTYPE" == darwin* ]]; then
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add --apple-use-keychain "$KEY_FILE" || ssh-add "$KEY_FILE"
else
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add "$KEY_FILE"
fi

chmod 600 "$KEY_FILE" "$KEY_FILE.pub"

# Print public key for convenience
echo "[ssh] Public key:" && echo && cat "$KEY_FILE.pub" && echo
echo "[ssh] Consider: gh auth login && gh ssh-key add $KEY_FILE.pub --title \"$(hostname)\""

