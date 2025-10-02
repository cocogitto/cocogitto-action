#!/bin/bash

set -euo pipefail

# Setup script for creating test repositories in various states
# Usage: setup-test-repo.sh <scenario> <test_dir>

SCENARIO="$1"
TEST_DIR="$2"

echo "Setting up test repository for scenario: $SCENARIO in $TEST_DIR"

# Create test directory and initialize git repo
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
git init

# Configure git user for test repo
git config user.name "Test User"
git config user.email "test@example.com"

case "$SCENARIO" in
"no-commits-since-tag")
  echo "# Test Repository" >README.md
  git add README.md
  git commit -m "feat: initial commit"

  echo "Initial content" >file1.txt
  git add file1.txt
  git commit -m "feat: add initial feature"

  echo "Bug fix content" >file2.txt
  git add file2.txt
  git commit -m "fix: resolve initial bug"

  # Tag the current commit - no commits after this tag
  git tag "v1.0.0"

  echo "Repository state: Has conventional commits, version tag on HEAD (no commits since tag)"
  ;;

"tag-on-current")
  echo "# Test Repository" >README.md
  git add README.md
  git commit -m "feat: initial commit"

  echo "Feature content" >feature.txt
  git add feature.txt
  git commit -m "feat: add new feature"

  echo "Another feature" >feature2.txt
  git add feature2.txt
  git commit -m "feat: add another feature"

  # Tag the current commit
  git tag "v1.1.0"

  echo "Repository state: Has conventional commits, version tag on current commit"
  ;;

"tag-before-current")
  echo "# Test Repository" >README.md
  git add README.md
  git commit -m "feat: initial commit"

  echo "Initial feature" >initial.txt
  git add initial.txt
  git commit -m "feat: add initial feature"

  # Tag an earlier commit
  git tag "v0.1.0"

  echo "New feature after tag" >new-feature.txt
  git add new-feature.txt
  git commit -m "feat: add feature after tag"

  echo "Bug fix after tag" >bugfix.txt
  git add bugfix.txt
  git commit -m "fix: fix bug after tag"

  echo "Chore after tag" >>README.md
  git add README.md
  git commit -m "chore: update documentation"

  echo "Repository state: Has version tag before current commit with new conventional commits"
  ;;

"mixed-commits")
  echo "# Test Repository" >README.md
  git add README.md
  git commit -m "feat: initial commit"

  echo "Feature" >feature.txt
  git add feature.txt
  git commit -m "feat: conventional commit"

  git tag "v0.1.0"

  echo "Non-conventional" >non-conv.txt
  git add non-conv.txt
  git commit -m "Add non-conventional commit"

  echo "Another feature" >feature2.txt
  git add feature2.txt
  git commit -m "feat: another conventional commit"

  echo "Repository state: Mixed conventional and non-conventional commits"
  ;;

"no-tags")
  echo "# Test Repository" >README.md
  git add README.md
  git commit -m "feat: initial commit"

  echo "Feature 1" >feature1.txt
  git add feature1.txt
  git commit -m "feat: add first feature"

  echo "Feature 2" >feature2.txt
  git add feature2.txt
  git commit -m "feat: add second feature"

  echo "Bug fix" >bugfix.txt
  git add bugfix.txt
  git commit -m "fix: resolve bug"

  echo "Repository state: Has conventional commits but no version tags"
  ;;

"dry-run")
  echo "# Test Repository" >README.md
  git add README.md
  git commit -m "feat: initial commit"

  echo "Initial feature" >feature.txt
  git add feature.txt
  git commit -m "feat: add initial feature"

  # Tag an earlier commit
  git tag "v0.1.0"

  echo "New feature for dry run test" >new-feature.txt
  git add new-feature.txt
  git commit -m "feat: add feature for dry run testing"

  echo "Bug fix for dry run test" >bugfix.txt
  git add bugfix.txt
  git commit -m "fix: fix bug for dry run testing"

  echo "Repository state: Has version tag before current commit - suitable for dry-run testing"
  ;;

*)
  echo "Unknown scenario: $SCENARIO"
  echo "Available scenarios: no-commits-since-tag, tag-on-current, tag-before-current, mixed-commits, no-tags, dry-run"
  exit 1
  ;;
esac

echo "Test repository setup complete!"
echo "Current git log:"
git log --oneline --decorate --all
echo ""
echo "Current tags:"
git tag -l || echo "No tags found"
