#!/bin/sh

VERSION=2.0.0
TAR="cocogitto-$VERSION-x86_64-unknown-linux-musl.tar.gz"

curl -OL https://github.com/oknozor/cocogitto/releases/download/"$VERSION"/"$TAR"
tar xfvz $TAR
./cog check
