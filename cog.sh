#!/bin/bash

set -a

CHECK="${1}"
LATEST_TAG_ONLY="${2}"
RELEASE="${3}"
GIT_USER="${4}"
GIT_USER_EMAIL="${5}"
VERIFY="${6}"
DRY_RUN="${7}"
PACKAGE="${8}"
PROFILE="${9}"
ADDITIONAL_ARGS_BUMP="${10}"

set -x
set -euo pipefail

echo "Setting git user : ${GIT_USER}"
git config --global user.name "${GIT_USER}"

echo "Settings git user email ${GIT_USER_EMAIL}"
git config --global user.email "${GIT_USER_EMAIL}"

cog --version

if [ "${CHECK}" = "true" ]; then
  if [ "${LATEST_TAG_ONLY}" = "true" ]; then
    if [ "$(git describe --tags --abbrev=0)" ]; then
      message="Checking commits from $(git describe --tags --abbrev=0)"
    else
      message="No tag found checking history from first commit"
    fi
    echo "${message}"
    cog check --from-latest-tag || exit 1
  else
    echo "Checking all commits"
    cog check || exit 1
  fi
fi

if [ "$RELEASE" = "true" ] && [ "$DRY_RUN" = "true" ]; then
    echo "ERROR: Impossible to release and dry run at the same time."
    exit 1
fi

OLD_VERSION="v$(cog get-version 2>/dev/null || echo "0.0.0")"
echo "Old version: $OLD_VERSION"
echo "old_version=$OLD_VERSION" >> "$GITHUB_OUTPUT"

# Initialize VERSION variable
VERSION=""

if [ "$DRY_RUN" = "true" ]; then
  echo "dry run"
  if [ "${PROFILE}" != '' ]; then
    echo "WARNING: bump profiles are ignored in dry run"
  fi
  cog bump --auto --dry-run ${ADDITIONAL_ARGS_BUMP} || exit 1
  VERSION="$(cog bump --auto --dry-run ${ADDITIONAL_ARGS_BUMP})"
  echo "version=$VERSION" >>$GITHUB_OUTPUT
fi

if [ "$RELEASE" = "true" ]; then
  if [ "$PACKAGE" != '' ]; then
      echo "packge=${PACKAGE}"
    if [ "$PROFILE" != '' ]; then
      echo "profile=${PROFILE}"
      cog bump --auto -H $PROFILE --package $PACKAGE ${ADDITIONAL_ARGS_BUMP} || exit 1
    else
      cog bump --auto --package $PACKAGE ${ADDITIONAL_ARGS_BUMP} || exit 1
    fi
  else
    if [ "$PROFILE" != '' ]; then
      echo "profile=${PROFILE}"
      cog bump --auto -H $PROFILE ${ADDITIONAL_ARGS_BUMP} || exit 1
    else
      cog bump --auto ${ADDITIONAL_ARGS_BUMP} || exit 1
    fi
  fi
  VERSION="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
  echo "version=$VERSION" >>$GITHUB_OUTPUT
fi

if [ ! -z "${VERSION}" ]; then
    # Generate changelog only if we have a valid old version (not the default 0.0.0)
    if [ "${OLD_VERSION}" != "0.0.0" ]; then
        CHANGELOG="$(cog changelog ${OLD_VERSION}..${VERSION})"
        printf "Changelog: \n\n%s" "${CHANGELOG}"
        echo "changelog<<EOF" >>"$GITHUB_OUTPUT"
        echo "${CHANGELOG}" >>"$GITHUB_OUTPUT"
        echo "EOF" >>"$GITHUB_OUTPUT"
    else
        # For first release, generate changelog from beginning
        CHANGELOG="$(cog changelog --at ${VERSION} 2>/dev/null || cog changelog)"
        printf "Changelog: \n\n%s" "${CHANGELOG}"
        echo "changelog<<EOF" >>"$GITHUB_OUTPUT"
        echo "${CHANGELOG}" >>"$GITHUB_OUTPUT"
        echo "EOF" >>"$GITHUB_OUTPUT"
    fi
fi

if (echo "${VERIFY}" | grep -Eiv '^([01]|(true)|(false))$' >/dev/null); then
  cog verify "${VERIFY}" || exit 1
fi
