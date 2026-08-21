#!/usr/bin/env bash
#
# sync.sh
# Commit and push all note changes with a timestamped message.
# Run from the repo root at the end of a session.
# Usage: ./snippets/sync.sh ["optional message"]

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Pulling first"
git pull --no-rebase

if git diff --quiet && git diff --staged --quiet && [[ -z "$(git status --porcelain)" ]]; then
  echo "==> Nothing to commit."
  exit 0
fi

MSG="${1:-notes: $(date '+%Y-%m-%d %H:%M')}"

git add -A
git commit -m "$MSG"
git push

echo "==> Done: $MSG"
