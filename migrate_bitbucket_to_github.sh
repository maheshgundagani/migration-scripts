#!/usr/bin/env bash
set -euo pipefail

BITBUCKET_USER="maheshemo1-admin"
BITBUCKET_WORKSPACE="maheshemo1"
GITHUB_USER="maheshgundagani"

while read -r REPO; do
  [ -z "$REPO" ] && continue

  echo "==============================="
  echo "Migrating repo: $REPO"
  echo "==============================="

  # If folder exists, skip clone
  if [ -d "$REPO" ]; then
    echo "Directory $REPO already exists, using existing clone"
    cd "$REPO"
  else
    git clone "https://${BITBUCKET_USER}@bitbucket.org/${BITBUCKET_WORKSPACE}/${REPO}.git"
    cd "$REPO"
  fi

  # Add GitHub remote if not already present
  if git remote | grep -q '^github$'; then
    echo "GitHub remote already exists"
  else
    git remote add github "https://github.com/${GITHUB_USER}/${REPO}.git"
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
