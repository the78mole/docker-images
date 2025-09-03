#!/usr/bin/env bash
set -euo pipefail

# Defaults
KEEP=3
DRY_RUN=false

usage() {
  echo "Usage: $0 [-k N] [-n]"
  echo ""
  echo "Options:"
  echo "  -k, --keep N     Number of newest workflow runs to keep (default: 3)"
  echo "  -n, --dry-run    Show what would be deleted, but do not delete"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -k|--keep)
      KEEP="$2"
      shift 2
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      usage
      ;;
  esac
done


# Get repo from current git remote
REPO=$(git remote get-url origin | sed -E 's/.*github.com[/:]//; s/\.git$//')
echo "Repo: $REPO"
if [[ -z "$REPO" ]]; then
  echo "❌ Could not determine GitHub repository from git remote."
  exit 1
fi

echo "🔎 Working on repository: $REPO"
echo "🧮 Fetching workflow runs..."

# Get all workflow run IDs sorted by creation date (newest first)
RUN_IDS=$(gh api "repos/$REPO/actions/runs?per_page=100" \
  --jq '.workflow_runs | sort_by(.created_at) | reverse | .[].id')

TOTAL_RUNS=$(echo "$RUN_IDS" | wc -l)
DELETE_COUNT=$((TOTAL_RUNS - KEEP))

if [[ "$DELETE_COUNT" -le 0 ]]; then
  echo "✅ Nothing to delete. ($TOTAL_RUNS total runs, keeping $KEEP)"
  exit 0
fi

echo "🗑️ Deleting $DELETE_COUNT of $TOTAL_RUNS workflow runs (keeping $KEEP)..."

export GH_PAGER=""

# Delete older runs
INDEX=0
echo "$RUN_IDS" | while read -r ID; do
  INDEX=$((INDEX + 1))
  if [[ "$INDEX" -le "$KEEP" ]]; then
    continue
  fi
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Would delete run ID: $ID"
  else
    echo "Deleting run ID: $ID"
    gh api -X DELETE "repos/$REPO/actions/runs/$ID"
  fi
done