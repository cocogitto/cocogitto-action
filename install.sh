#!/bin/sh

CUR_DIR=$(pwd)
VERSION=5.3.0
TAR="cocogitto-$VERSION-x86_64-unknown-linux-musl.tar.gz"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"
cd "$BIN_DIR" || exit
curl -OL https://github.com/cocogitto/cocogitto/releases/download/"$VERSION"/"$TAR"
tar xfz $TAR
cd "$CUR_DIR" || exit
