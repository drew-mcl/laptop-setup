#!/usr/bin/env bash
set -euo pipefail

REPO_PATH="${1:-}"
if [ -z "$REPO_PATH" ]; then
  echo "Usage: make git-monorepo REPO=/path/to/repo"
  exit 1
fi

if [ ! -d "$REPO_PATH/.git" ]; then
  echo "[git-monorepo] Not a git repo: $REPO_PATH"
  exit 1
fi

echo "[git-monorepo] Applying repo-local performance settings to $REPO_PATH ..."

git -C "$REPO_PATH" config --local core.untrackedCache true || true
git -C "$REPO_PATH" config --local pack.writeBitmaps true || true
git -C "$REPO_PATH" config --local index.version 4 || true
git -C "$REPO_PATH" config --local feature.manyFiles true || true
git -C "$REPO_PATH" config --local gc.auto 0 || true
git -C "$REPO_PATH" config --local gc.writeCommitGraph true || true
git -C "$REPO_PATH" config --local commitGraph.generationVersion 2 || true
git -C "$REPO_PATH" config --local fetch.parallel 16 || true

# Enable fsmonitor if watchman is available
if command -v watchman >/dev/null 2>&1; then
  git -C "$REPO_PATH" config --local core.fsmonitor true || true
else
  echo "[git-monorepo] watchman not found; skipping fsmonitor"
fi

# Optional one-time optimizations (safe to skip on huge repos if time constrained)
if [ "${RUN_DEEP_OPTIMIZE:-0}" = "1" ]; then
  echo "[git-monorepo] Running deep optimization (may take a while)..."
  git -C "$REPO_PATH" repack -Adk --write-bitmap-index --threads=0 || true
  git -C "$REPO_PATH" gc --prune=now || true
fi

echo "[git-monorepo] Done. Consider: git -C $REPO_PATH maintenance start"

