#!/usr/bin/env bash
set -euo pipefail

# Determine the automerge strategy based on the Dependabot update type
# and user-configured strategies for each semver level.
#
# Required env vars:
#   UPDATE_TYPE       - Dependabot update type (e.g. "version-update:semver-patch")
#   PATCH_STRATEGY    - Strategy for patch updates
#   MINOR_STRATEGY    - Strategy for minor updates
#   MAJOR_STRATEGY    - Strategy for major updates
#
# Outputs (via $GITHUB_OUTPUT):
#   strategy    - The resolved strategy name
#   update-type - The semver level (patch, minor, major)

VALID_STRATEGIES=("auto-merge" "review-and-merge" "review-only" "none")

validate_strategy() {
  local name="$1"
  local value="$2"
  for valid in "${VALID_STRATEGIES[@]}"; do
    if [[ "$value" == "$valid" ]]; then
      return 0
    fi
  done
  echo "::error::Invalid ${name}: '${value}'. Must be one of: ${VALID_STRATEGIES[*]}"
  exit 1
}

validate_strategy "patch-strategy" "$PATCH_STRATEGY"
validate_strategy "minor-strategy" "$MINOR_STRATEGY"
validate_strategy "major-strategy" "$MAJOR_STRATEGY"

case "$UPDATE_TYPE" in
  version-update:semver-patch)
    STRATEGY="$PATCH_STRATEGY"
    SEMVER_LEVEL="patch"
    ;;
  version-update:semver-minor)
    STRATEGY="$MINOR_STRATEGY"
    SEMVER_LEVEL="minor"
    ;;
  *)
    STRATEGY="$MAJOR_STRATEGY"
    SEMVER_LEVEL="major"
    ;;
esac

echo "::notice::Dependabot update type: ${UPDATE_TYPE} (${SEMVER_LEVEL}) -> strategy: ${STRATEGY}"

echo "strategy=${STRATEGY}" >> "$GITHUB_OUTPUT"
echo "update-type=${SEMVER_LEVEL}" >> "$GITHUB_OUTPUT"
