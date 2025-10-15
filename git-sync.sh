#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./git-sync.sh "your commit message"
# If no message is provided, a timestamped default is used.

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a Git repository."
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
MSG="${1:-chore: sync on $(date -u +'%Y-%m-%d %H:%M:%S') UTC}"
ROOT="$(git rev-parse --show-toplevel)"

echo "📦 Repo: $(basename "$ROOT")"
echo "🌿 Branch: $BRANCH"

# -------------------------------
# 🔤 Rename files to consistent style
# Example: "13. Roman to Integer.py" → "13-roman-to-integer.py"
# -------------------------------
echo "🧹 Renaming files for consistency..."
find "$ROOT" -type f -name "*.py" | while read -r f; do
  dirname="$(dirname "$f")"
  base="$(basename "$f")"
  # Match "13. Roman to Integer.py"
  if [[ "$base" =~ ^([0-9]+)\.\ (.*)\.py$ ]]; then
    num="${BASH_REMATCH[1]}"
    title="${BASH_REMATCH[2]}"
    # Replace spaces with '-' and lowercase everything
    slug="$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9\-')"
    newname="${dirname}/${num}-${slug}.py"
    if [[ "$f" != "$newname" ]]; then
      echo "→ $base  →  $(basename "$newname")"
      mv "$f" "$newname"
    fi
  fi
done
echo "✅ Rename check complete."

# -------------------------------
# 🔁 Sync operations
# -------------------------------
echo "⬇️  Fetching..."
git fetch --all --prune

echo "🔁 Pulling with rebase..."
git pull --rebase origin "$BRANCH"

echo "➕ Staging changes..."
git add -A

if ! git diff --cached --quiet; then
  echo "✅ Committing: $MSG"
  git commit -m "$MSG"
else
  echo "ℹ️  No staged changes to commit."
fi

echo "⬆️  Pushing..."
git push origin "$BRANCH"

echo "🎉 Done."
