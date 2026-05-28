#!/usr/bin/env bash
set -euo pipefail

# Check the AI reviewer's approval status and enable auto-merge if approved.
#
# Required env vars:
#   GH_TOKEN        - GitHub token with PR write permissions
#   PR_URL          - Full URL of the pull request
#   PR_NUMBER       - Pull request number
#   REVIEWER_LOGIN  - Bot login name to check (optional; if empty, checks the latest review)

echo "::group::Conditional merge after AI review"

REVIEWS_JSON=$(gh pr view "$PR_NUMBER" --json reviews)

# gh pr view --json (GraphQL) returns bot logins without the [bot] suffix,
# e.g. "deps-keeper" instead of "deps-keeper[bot]". Strip it for comparison.
REVIEWER_LOGIN_CLEAN="${REVIEWER_LOGIN/%\[bot\]/}"

if [[ -n "${REVIEWER_LOGIN}" ]]; then
  echo "Checking review state from: ${REVIEWER_LOGIN} (matching: ${REVIEWER_LOGIN_CLEAN})"
  REVIEW_STATE=$(echo "$REVIEWS_JSON" | jq -r \
    "[.reviews[] | select(.author.login == \"${REVIEWER_LOGIN_CLEAN}\")] | last | .state // empty")
else
  echo "No reviewer-login specified — checking latest review"
  REVIEW_STATE=$(echo "$REVIEWS_JSON" | jq -r \
    '.reviews | last | .state // empty')
fi

echo "review-state=${REVIEW_STATE}" >> "$GITHUB_OUTPUT"

if [[ "$REVIEW_STATE" == "APPROVED" ]]; then
  echo "✅ AI review approved — merging"
  gh pr merge "$PR_URL" --merge
  echo "merged=true" >> "$GITHUB_OUTPUT"
else
  echo "⚠️ AI review did not approve (state: ${REVIEW_STATE}) — skipping auto-merge"
  echo "merged=false" >> "$GITHUB_OUTPUT"
fi

echo "::endgroup::"
