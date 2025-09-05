#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/repos/personal" "$HOME/repos/work" "$HOME/repos/archive"
mkdir -p "$HOME/.local/bin" "$HOME/bin" "$HOME/tmp"

echo "[dirs] Ensured: ~/repos/{personal,work,archive}, ~/.local/bin, ~/bin, ~/tmp"

