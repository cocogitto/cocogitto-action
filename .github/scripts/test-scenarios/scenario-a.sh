#!/bin/bash

set -euo pipefail

# Test scenario A: Repositories with conventional commits but no commits since last version tag
# Expected behavior: Should not create a new release since HEAD is already tagged

SCENARIO="no-commits-since-tag"
TEST_DIR="$RUNNER_TEMP/test-repos/scenario-a"
ACTION_PATH="$GITHUB_WORKSPACE/cocogitto-action"

echo "=== Testing Scenario A: No commits since last tag ==="

# Setup test repository
bash "$ACTION_PATH/.github/scripts/setup-test-repo.sh" "$SCENARIO" "$TEST_DIR"

# Change to test directory for action execution
cd "$TEST_DIR"

echo "Running cocogitto-action with release=true, check=false..."

# Run the action (simulating GitHub Actions environment)
export GITHUB_OUTPUT="$RUNNER_TEMP/github_output_scenario_a.txt"
export GITHUB_ACTION_PATH="$ACTION_PATH"

# Install cocogitto first
bash "$ACTION_PATH/install.sh"
export PATH="$HOME/.local/bin:$PATH"

# Execute the action with release enabled, check disabled
bash "$ACTION_PATH/cog.sh" \
  "false" \
  "false" \
  "true" \
  "Test Bot" \
  "test@example.com" \
  "false" \
  "false" \
  "" \
  ""

echo "Action execution completed. Checking outputs..."

# Validate outputs
if [[ -f "$GITHUB_OUTPUT" ]]; then
  echo "GitHub outputs:"
  cat "$GITHUB_OUTPUT"

  # Extract outputs
  VERSION=$(grep "^version=" "$GITHUB_OUTPUT" | cut -d'=' -f2 || echo "")
  OLD_VERSION=$(grep "^old_version=" "$GITHUB_OUTPUT" | cut -d'=' -f2 || echo "")

  echo "Version: $VERSION"
  echo "Old Version: $OLD_VERSION"

  # For this scenario, we expect a version to be created (since we run with release=true)
  if [[ -n "$VERSION" ]]; then
    echo "✓ Version created: $VERSION"
  else
    echo "✗ Expected version to be created"
    exit 1
  fi
else
  echo "✗ No GitHub output file found"
  exit 1
fi

# Validate repository state
bash "$ACTION_PATH/.github/scripts/validate-outputs.sh" "$SCENARIO" "$TEST_DIR" "no-new-release"

echo "✓ Scenario A test completed successfully"
