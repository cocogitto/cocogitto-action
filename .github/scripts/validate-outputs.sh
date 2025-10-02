#!/bin/bash

set -euo pipefail

# Validation script for cocogitto-action outputs
# Usage: validate-outputs.sh <scenario> <test_dir> <expected_behavior>

SCENARIO="$1"
TEST_DIR="$2"
EXPECTED_BEHAVIOR="$3"

echo "Validating outputs for scenario: $SCENARIO"
echo "Expected behavior: $EXPECTED_BEHAVIOR"

cd "$TEST_DIR"

# Function to validate version format
validate_version_format() {
  local version="$1"
  if [[ "$version" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    echo "✓ Version format is valid: $version"
    return 0
  else
    echo "✗ Invalid version format: $version"
    return 1
  fi
}

# Function to check if git repository state is clean
check_repo_isolation() {
  echo "Checking repository isolation..."

  # Verify we're in the test directory, not the main repo
  if [[ "$(pwd)" != *"$TEST_DIR"* ]]; then
    echo "✗ Not in expected test directory: $(pwd)"
    return 1
  fi

  # Check that we have a .git directory (this is our test repo)
  if [[ ! -d ".git" ]]; then
    echo "✗ No .git directory found in test repo"
    return 1
  fi

  echo "✓ Repository isolation verified"
  return 0
}

# Function to validate changelog format
validate_changelog() {
  local changelog="$1"

  if [[ -z "$changelog" ]]; then
    echo "! Changelog is empty (may be expected for some scenarios)"
    return 0
  fi

  # Basic changelog validation - should contain version info or commit info
  if [[ "$changelog" =~ (feat|fix|chore|docs|style|refactor|perf|test) ]]; then
    echo "✓ Changelog contains conventional commit types"
    return 0
  else
    echo "! Changelog format may be unexpected: $changelog"
    return 0 # Don't fail on this, just warn
  fi
}

# Main validation logic based on scenario
case "$SCENARIO" in
"no-commits-since-tag")
  echo "Validating scenario: No commits since last tag"

  # After running the action with release=true, a new tag should have been created
  TAG_COUNT=$(git tag -l | wc -l)
  if [[ "$TAG_COUNT" -ge 1 ]]; then
    echo "✓ Found $TAG_COUNT tag(s) after release"
    LATEST_TAG=$(git describe --tags --abbrev=0)
    echo "✓ Latest tag: $LATEST_TAG"
  else
    echo "✗ Expected at least one tag after release"
    exit 1
  fi
  ;;

"tag-on-current")
  echo "Validating scenario: Tag on current commit"

  # After running the action with release=true, a new tag should have been created
  TAG_COUNT=$(git tag -l | wc -l)
  if [[ "$TAG_COUNT" -ge 1 ]]; then
    echo "✓ Found $TAG_COUNT tag(s) after release"
    LATEST_TAG=$(git describe --tags --abbrev=0)
    echo "✓ Latest tag: $LATEST_TAG"
  else
    echo "✗ Expected at least one tag after release"
    exit 1
  fi
  ;;

"tag-before-current")
  echo "Validating scenario: Tag before current commit"

  # After running the action with release=true, a new tag should have been created
  # So we should have at least one tag
  TAG_COUNT=$(git tag -l | wc -l)
  if [[ "$TAG_COUNT" -ge 1 ]]; then
    echo "✓ Found $TAG_COUNT tag(s) after release"
    LATEST_TAG=$(git describe --tags --abbrev=0)
    echo "✓ Latest tag: $LATEST_TAG"
  else
    echo "✗ Expected at least one tag after release"
    exit 1
  fi
  ;;

"mixed-commits")
  echo "Validating scenario: Mixed conventional/non-conventional commits"

  # Check for both conventional and non-conventional commits
  CONV_COMMITS=$(git log --oneline --grep="^feat\|^fix\|^chore\|^docs" | wc -l)
  TOTAL_COMMITS=$(git log --oneline | wc -l)

  echo "Found $CONV_COMMITS conventional commits out of $TOTAL_COMMITS total"

  if [[ "$CONV_COMMITS" -gt 0 ]] && [[ "$CONV_COMMITS" -lt "$TOTAL_COMMITS" ]]; then
    echo "✓ Repository has mixed commit types"
  else
    echo "! Repository may not have expected mix of commit types"
  fi
  ;;

"no-tags")
  echo "Validating scenario: No tags"

  # For this scenario, we expect that after running the action with release=true,
  # a tag should have been created (since it's a release action)
  TAG_COUNT=$(git tag -l | wc -l)
  if [[ "$TAG_COUNT" -eq 1 ]]; then
    echo "✓ Repository has 1 tag as expected after release"
  else
    echo "✗ Expected 1 tag after release, found $TAG_COUNT"
    exit 1
  fi
  ;;

"dry-run")
  echo "Validating scenario: Dry run"

  # For dry-run, no new tags should be created and no actual releases should happen
  # The repository should remain in its original state
  TAG_COUNT=$(git tag -l | wc -l)
  if [[ "$TAG_COUNT" -eq 1 ]]; then
    echo "✓ Repository still has original tag (dry-run didn't create new tags)"
    LATEST_TAG=$(git describe --tags --abbrev=0)
    echo "✓ Original tag preserved: $LATEST_TAG"
  else
    echo "✗ Expected 1 original tag after dry-run, found $TAG_COUNT"
    exit 1
  fi

  # Check that we still have commits after the tag (dry-run shouldn't change commit history)
  COMMITS_SINCE_TAG=$(git rev-list --count HEAD ^$(git describe --tags --abbrev=0))
  if [[ "$COMMITS_SINCE_TAG" -gt 0 ]]; then
    echo "✓ Found $COMMITS_SINCE_TAG commits since tag (dry-run preserved commit history)"
  else
    echo "✗ Expected commits since tag after dry-run"
    exit 1
  fi
  ;;

*)
  echo "Unknown scenario for validation: $SCENARIO"
  exit 1
  ;;
esac

# Always check repository isolation
check_repo_isolation

echo "Validation completed for scenario: $SCENARIO"
