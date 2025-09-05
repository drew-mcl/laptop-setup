#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

echo "[bootstrap] Running pre-brew configuration..."
"$ROOT_DIR/scripts/bootstrap-prebrew.sh"

if ! command -v brew >/dev/null 2>&1; then
  echo "[bootstrap] Homebrew not found. Install it using your internal tool, then re-run this script."
  exit 1
fi

echo "[bootstrap] Installing minimal tools via brew: stow and make..."
brew list stow >/dev/null 2>&1 || brew install stow
brew list make >/dev/null 2>&1 || brew install make

echo "[bootstrap] Done. Next steps:"
echo "  1) Optionally: bash scripts/ssh-setup.sh"
echo "  2) Install full toolchain: make install"

