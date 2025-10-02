#!/bin/bash

set -euo pipefail

# Cleanup script for test environments
# Usage: cleanup-test-env.sh [test_dir]

TEST_DIR="${1:-$RUNNER_TEMP/test-repos}"

echo "Cleaning up test environment: $TEST_DIR"

if [[ -d "$TEST_DIR" ]]; then
  echo "Removing test directory: $TEST_DIR"
  rm -rf "$TEST_DIR"
  echo "✓ Test directory cleaned up"
else
  echo "! Test directory does not exist: $TEST_DIR"
fi

# Clean up any temporary files that might have been created
if [[ -n "${RUNNER_TEMP:-}" ]]; then
  find "$RUNNER_TEMP" -name "github_output.txt" -delete 2>/dev/null || true
  find "$RUNNER_TEMP" -name "*.tmp" -delete 2>/dev/null || true
  echo "✓ Temporary files cleaned up"
fi

echo "Cleanup completed"
