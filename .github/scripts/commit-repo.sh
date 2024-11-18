#!/bin/bash
set -e

# Sync files while excluding certain files
rsync -a --delete --exclude .git --exclude .gitignore --exclude README.md --exclude repo.json ../main/repo/ .

# Set Git configuration
git config --global user.email "156965415+akitachi7@users.noreply.github.com"
git config --global user.name "akitachi7"

# Check for changes
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Update extensions repo"
    git push

    # Purge CDN or update resource
    curl -X POST -d @repo/index.min.json https://purge.jsdelivr.net/gh/akitachi7/tachiomi-extensions
else
    echo "No changes to commit"
fi