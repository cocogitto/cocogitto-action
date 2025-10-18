#!/bin/sh

CURRENT_VERSION=$1
CURRENT_MAJOR=$(echo $CURRENT_VERSION | awk -F. '{print $1}')
git push --delete origin $CURRENT_MAJOR || echo "$CURRENT_MAJOR not found, skipping"
git push origin $CURRENT_MAJOR
