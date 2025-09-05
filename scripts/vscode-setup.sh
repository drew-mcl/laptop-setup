#!/usr/bin/env bash
set -euo pipefail

EXT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/vscode/extensions.txt"
LOCAL_BIN="$HOME/.local/bin"

# Ensure local bin is in PATH for this script
export PATH="$LOCAL_BIN:$PATH"

# Try to create a user-writable symlink for VS Code CLI if missing
if ! command -v code >/dev/null 2>&1; then
  APP_CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [ -x "$APP_CLI" ]; then
    mkdir -p "$LOCAL_BIN"
    ln -sf "$APP_CLI" "$LOCAL_BIN/code"
    echo "[vscode] Linked 'code' CLI to $LOCAL_BIN/code"
  fi
fi

if ! command -v code >/dev/null 2>&1; then
  echo "[vscode] 'code' CLI not found. Ensure VS Code is installed and 'Shell Command: Install 'code' command' is enabled."
  exit 0
fi

if [ -f "$EXT_FILE" ]; then
  echo "[vscode] Installing extensions from $EXT_FILE ..."
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" =~ ^# ]] && continue
    code --install-extension "$ext" || true
  done < "$EXT_FILE"
else
  echo "[vscode] No extensions.txt found. Skipping extensions."
fi

echo "[vscode] Done. Settings are stowed under your Code/User directory if you ran 'make stow'."
