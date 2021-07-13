#!/bin/sh

set -a

VERSION=2.1.1
TAR="cocogitto-$VERSION-x86_64-unknown-linux-musl.tar.gz"
CHECK=$1
LATEST_TAG_ONLY=$2
RELEASE=$3
GIT_USER=$4
GIT_USER_EMAIL=$5
CUR_DIR=$(pwd)
BIN_DIR=/home/runner/work/bin


echo "Setting git user : $GIT_USER"
git config --global user.name "$GIT_USER"

echo "Settings git user email $GIT_USER_EMAIL"
git config --global user.email "$GIT_USER_EMAIL"

mkdir -p "$BIN_DIR"
cd "$BIN_DIR" || exit
curl -OL https://github.com/oknozor/cocogitto/releases/download/"$VERSION"/"$TAR"
tar xfz $TAR

cd "$CUR_DIR" || exit

if [ "$CHECK" = "true" ]; then
  if [ "$LATEST_TAG_ONLY" = "true" ]; then
    if [ "$(git describe --abbrev=0)" ]; then
      message="Checking commits from $(git describe --abbrev=0)"
    else
      message="No tag found checking history from first commit"
    fi
      echo "$message"
      "$BIN_DIR"/./cog check --from-latest-tag
  else
     echo "Checking all commits"
     "$BIN_DIR"/./cog check
  fi
fi

if [ "$RELEASE" = "true" ]; then
   "$BIN_DIR"/./cog bump --auto
fi