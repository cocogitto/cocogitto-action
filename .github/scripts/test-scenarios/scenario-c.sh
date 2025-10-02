#!/bin/bash

set -euo pipefail

# Test scenario C: Repositories where the last version tag is before the current commit
# Expected behavior: Should create a new release based on conventional commits since the tag

SCENARIO="tag-before-current"
TEST_DIR="$RUNNER_TEMP/test-repos/scenario-c"
ACTION_PATH="$GITHUB_WORKSPACE/cocogitto-action"

echo "=== Testing Scenario C: Tag before current commit ==="

# Setup test repository
bash "$ACTION_PATH/.github/scripts/setup-test-repo.sh" "$SCENARIO" "$TEST_DIR"

# Change to test directory for action execution
cd "$TEST_DIR"

echo "Running cocogitto-action with release=true, check=false..."

# Run the action (simulating GitHub Actions environment)
export GITHUB_OUTPUT="$RUNNER_TEMP/github_output_scenario_c.txt"
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

  # For this scenario, we expect a new version to be created (should be > v0.1.0)
  if [[ -n "$VERSION" ]] && [[ "$VERSION" != "v0.1.0" ]]; then
    echo "✓ New version created: $VERSION"

    # Validate that old version is reasonable (could be 0.0.0 for first release or the previous tag)
    if [[ "$OLD_VERSION" == "v0.1.0" ]] || [[ "$OLD_VERSION" == "0.0.0" ]]; then
      echo "✓ Old version correctly identified: $OLD_VERSION"
    else
      echo "✗ Unexpected old version: $OLD_VERSION (expected v0.1.0 or 0.0.0)"
      exit 1
    fi
  else
    echo "✗ Expected new version to be created, got: $VERSION"
    exit 1
  fi

  # Check if changelog was generated
  if grep -q "changelog<<EOF" "$GITHUB_OUTPUT"; then
    echo "✓ Changelog was generated"
  else
    echo "! No changelog found in output"
  fi
else
  echo "✗ No GitHub output file found"
  exit 1
fi

# Validate repository state
bash "$ACTION_PATH/.github/scripts/validate-outputs.sh" "$SCENARIO" "$TEST_DIR" "new-release"

# Check that a new tag was created
LATEST_TAG=$(git describe --tags --abbrev=0)
if [[ "$LATEST_TAG" != "v0.1.0" ]]; then
  echo "✓ New tag created: $LATEST_TAG"
else
  echo "✗ Expected new tag to be created"
  exit 1
fi

echo "✓ Scenario C test completed successfully"
