#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CUSTOM_DIR="$ROOT_DIR/custom"

if [ ! -d "$CUSTOM_DIR" ]; then
  echo "[custom] No custom/ directory found. Skipping."
  exit 0
fi

found=0
for f in "$CUSTOM_DIR"/*.sh; do
  if [ -f "$f" ]; then
    echo "[custom] Running: $f"
    bash "$f"
    found=1
  fi
done

if [ "$found" -eq 0 ]; then
  echo "[custom] No executable .sh files in custom/"
fi

