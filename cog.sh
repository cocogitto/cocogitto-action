#!/bin/sh

set -a

GIT_USER="${1}"
GIT_USER_EMAIL="${2}"
COMMAND="${3}"
ARGS="${4}"

echo "Setting git user: $GIT_USER"
git config --global user.name "$GIT_USER"

echo "Setting git user email: $GIT_USER_EMAIL"
git config --global user.email "$GIT_USER_EMAIL"

cog --version

if [ -z "$COMMAND" ]; then
  echo "Error: No command specified"
  exit 1
fi

echo "Running command: cog $COMMAND $ARGS"
cog $COMMAND $ARGS || exit 1

if [ "$COMMAND" = "release" ] || [ "$COMMAND" = "bump" ]; then
  VERSION="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
  echo "version=$VERSION" >>$GITHUB_OUTPUT
fi
