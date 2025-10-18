#!/bin/sh

CUR_DIR=$(pwd)
VERSION=6.3.0
BIN_DIR="$HOME/.local/bin"

PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)


case $PLATFORM in
    linux|darwin|mingw*)
        case $ARCH in
            x86_64|amd64) ARCH="x86_64" ;;
            aarch64|arm64) ARCH="aarch64" ;;
            armv7l) ARCH="armv7" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        ;;
    *) echo "Unsupported platform: $PLATFORM"; exit 1 ;;
esac

case $PLATFORM in
    linux)
        case $ARCH in
            x86_64) PLATFORM="unknown-linux-musl" ;;
            aarch64) PLATFORM="unknown-linux-gnu" ;;
            armv7) PLATFORM="unknown-linux-musleabihf" ;;
            *) echo "Unsupported platform and architecture combination"; exit 1 ;;
        esac
        ;;
    darwin) PLATFORM="apple-darwin" ;;
    mingw*) PLATFORM="pc-windows-msvc" ;;
    *) echo "Unsupported platform: $PLATFORM"; exit 1 ;;
esac

TAR="cocogitto-$VERSION-$ARCH-$PLATFORM.tar.gz"
echo "Downloading cocogitto version $VERSION for $ARCH-$PLATFORM from https://github.com/cocogitto/cocogitto/releases/download/$VERSION/$TAR"

mkdir -p "$BIN_DIR"
cd "$BIN_DIR" || exit
curl -OL https://github.com/cocogitto/cocogitto/releases/download/"$VERSION"/"$TAR"
tar --strip-components=1 -xzf $TAR "$ARCH-$PLATFORM/cog"
cd "$CUR_DIR" || exit
