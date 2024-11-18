#!/bin/bash
set -e

rsync -a --delete --exclude .git --exclude .gitignore --exclude README.md --exclude repo.json ../main/repo/ .
git config --global user.email "156965415+akitachi7@users.noreply.github.com"
git config --global user.name "akitachi7"
git status
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Update extensions repo"
    git push

    curl https://purge.jsdelivr.net/gh/akitachi7/tachiomi-extensions @repo/index.min.json
else
    echo "No changes to commit"
fi
