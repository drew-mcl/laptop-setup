#!/usr/bin/env bash
set -euo pipefail

ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$ZSH_DIR" ]; then
  echo "[oh-my-zsh] Already installed at $ZSH_DIR"
  exit 0
fi

echo "[oh-my-zsh] Installing..."
export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "[oh-my-zsh] Installed. You can now 'chsh -s /bin/zsh' if desired."

