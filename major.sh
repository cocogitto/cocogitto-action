#!/bin/sh
CURRENT_VERSION=$1
CURRENT_MAJOR=$(echo $CURRENT_VERSION | awk -F. '{print $1}')
if ! git rev-parse $CURRENT_MAJOR >/dev/null 2>&1; then
    git tag $CURRENT_MAJOR
    git push origin $CURRENT_MAJOR
else
  echo "$CURRENT_MAJOR already exists, skipping tagging"
fi
