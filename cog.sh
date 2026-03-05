#!/bin/sh

set -a

COMMAND="${1}"
shift
ARGS="${*}"

cog --version

if [ -z "$COMMAND" ]; then
  echo "Error: No command specified"
  exit 1
fi

echo "Running command: cog $COMMAND $ARGS"
stdout="$(cog $COMMAND $ARGS 2>&1)"
exit_code=$?
{
  echo "stdout<<EOF"
  echo "$stdout"
  echo "EOF"
} >> "$GITHUB_OUTPUT"
echo "$stdout"
[ $exit_code -ne 0 ] && exit $exit_code

if [ "$COMMAND" = "release" ] || [ "$COMMAND" = "bump" ]; then
  VERSION="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
  echo "version=$VERSION" >>"$GITHUB_OUTPUT"
fi
