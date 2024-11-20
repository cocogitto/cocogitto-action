#!/bin/sh

set -a

CHECK="${1}"
LATEST_TAG_ONLY="${2}"
RELEASE="${3}"
GIT_USER="${4}"
GIT_USER_EMAIL="${5}"
VERIFY="${6}"
PROFILE="${7}"
IGNORE_MERGE_COMMITs="${8}"

echo "Setting git user : ${GIT_USER}"
git config --global user.name "${GIT_USER}"

echo "Settings git user email ${GIT_USER_EMAIL}"
git config --global user.email "${GIT_USER_EMAIL}"

cog --version

if [ "${CHECK}" = "true" ]; then
  flags=""
  if [ "${IGNORE_MERGE_COMMITs}" = "true" ]; then
    flags="$flags --ignore-merge-commits"
  fi
  if [ "${LATEST_TAG_ONLY}" = "true" ]; then
    flags="$flags --from-latest-tag"
    if [ "$(git describe --tags --abbrev=0)" ]; then
      message="Checking commits from $(git describe --tags --abbrev=0)"
    else
      message="No tag found checking history from first commit"
    fi
    echo "${message}"
  else
    echo "Checking all commits"
  fi
  cog check $flags || exit 1
fi

if [ "$RELEASE" = "true" ]; then
  if [ "$PROFILE" != '' ]; then
    echo "profile=${PROFILE}"
    cog bump --auto -H $PROFILE || exit 1
  else
    cog bump --auto || exit 1
  fi
  VERSION="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
  echo "version=$VERSION" >> $GITHUB_OUTPUT
fi

if ( echo "${VERIFY}" | grep -Eiv '^([01]|(true)|(false))$' > /dev/null ) ; then
  cog verify "${VERIFY}" || exit 1
fi
