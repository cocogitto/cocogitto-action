#!/bin/sh

set -a

CHECK="${1}"
LATEST_TAG_ONLY="${2}"
RELEASE="${3}"
GIT_USER="${4}"
GIT_USER_EMAIL="${5}"
VERIFY="${6}"
DRY_RUN="${7}"
PROFILE="${8}"
PACKAGE="${9}"

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

if [ "$DRY_RUN" = "true" ]; then
  echo "dry run"
  echo "a'${PROFILE}'a"
  if [ "${PROFILE}" != ' ' ]; then
    echo "WARNING: bump profiles are ignored in dry run"
  fi
      cog bump --auto  --dry-run|| exit 1
  VERSION="$(cog bump --auto  --dry-run)"
  echo "version=$VERSION" >>$GITHUB_OUTPUT
fi

if [ "$RELEASE" = "true" ]; then
  if [ "$PACKAGE" != '' ]; then
    if [ "$PROFILE" != '' ]; then
      echo "packge=${PACKAGE} profile=${PROFILE}"
      cog bump --auto -H $PROFILE --package $PACKAGE || exit 1
    else
      cog bump --auto --package $PACKAGE || exit 1
    fi
  else
    if [ "$PROFILE" != '' ]; then
      echo "profile=${PROFILE}"
      cog bump --auto -H $PROFILE || exit 1
    else
      cog bump --auto || exit 1
    fi
  fi
  VERSION="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
  echo "version=$VERSION" >>$GITHUB_OUTPUT
fi

if (echo "${VERIFY}" | grep -Eiv '^([01]|(true)|(false))$' >/dev/null); then
  cog verify "${VERIFY}" || exit 1
fi
