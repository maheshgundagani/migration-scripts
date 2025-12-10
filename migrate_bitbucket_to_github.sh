#!/usr/bin/env bash
set -euo pipefail

# These must be provided as env vars (Jenkins will set them)
: "${BITBUCKET_USER:?BITBUCKET_USER not set}"
: "${BITBUCKET_PASS:?BITBUCKET_PASS not set}"
: "${BITBUCKET_WORKSPACE:?BITBUCKET_WORKSPACE not set}"
: "${GITHUB_USER:?GITHUB_USER not set}"
: "${GITHUB_PAT:?GITHUB_PAT not set}"

while read -r REPO; do
  [ -z "$REPO" ] && continue

  echo "==============================="
  echo "Migrating repo: $REPO"
  echo "==============================="

  # Clone from Bitbucket (with credentials)
  if [ -d "$REPO" ]; then
    echo "Directory $REPO already exists, using existing clone"
    cd "$REPO"
    git remote set-url origin "https://${BITBUCKET_USER}:${BITBUCKET_PASS}@bitbucket.org/${BITBUCKET_WORKSPACE}/${REPO}.git"
  else
    git clone "https://${BITBUCKET_USER}:${BITBUCKET_PASS}@bitbucket.org/${BITBUCKET_WORKSPACE}/${REPO}.git"
    cd "$REPO"
  fi

  # Configure GitHub remote with PAT
  if git remote | grep -q '^github$'; then
    git remote set-url github "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_USER}/${REPO}.git"
  else
    git remote add github "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_USER}/${REPO}.git"
  fi

  git remote -v

  echo "Pushing all branches..."
  git push github --all

  echo "Pushing all tags..."
  git push github --tags

  cd ..
  echo "Finished repo: $REPO"
  echo
done < repos.txt
