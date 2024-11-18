#!/bin/bash
set -e

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dir) REPO_DIR="$2"; shift ;;
        --CDN) CDN_LINK="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Ensure that both the directory and CDN link are provided
if [ -z "$REPO_DIR" ]; then
    echo "Error: --dir flag is required"
    exit 1
fi

if [ -z "$CDN_LINK" ]; then
    echo "Error: --CDN flag is required"
    exit 1
fi

# Sync files while excluding certain files
rsync -a --delete --exclude .git --exclude .gitignore --exclude README.md --exclude repo.json ../main/"$REPO_DIR"/ .

# Set Git configuration
git config --global user.email "156965415+akitachi7@users.noreply.github.com"
git config --global user.name "akitachi7"

# Check for changes
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Update extensions repo"
    git push

    # Purge CDN or update resource
    curl -X POST -d @repo/index.min.json "$CDN_LINK"
#    curl -X POST -d @repo/index.min.json https://purge.jsdelivr.net/gh/akitachi7/tachiomi-extensions
else
    echo "No changes to commit"
fi