#!/usr/bin/env bash
set -euo pipefail

# Approve and enable auto-merge on a Dependabot PR.
#
# Required env vars:
#   GH_TOKEN   - GitHub token with PR write permissions
#   PR_URL     - Full URL of the pull request

echo "::group::Approve & auto-merge"

gh pr review "$PR_URL" --approve --body "🤖 Auto-approved by dependabot-automerge action."
echo "✅ PR approved"

gh pr merge "$PR_URL" --auto --merge
echo "✅ Auto-merge enabled"

echo "::endgroup::"
