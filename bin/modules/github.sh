#!/bin/bash

echo "Pushing git repo to GitHub"

curl --fail --silent https://github.com/${github_owner}/${REPO_NAME} > /dev/null

# Checking if repo exists on github.
if [ $? -ne 0 ]; then
    echo "Warning: GitHub-Project ${REPO_NAME} does not exist"
    echo "go to https://github.com/new to create the repo '$REPO_NAME'."
    return # no project on github, exiting without error
fi

ssh -q git@github.com

if [ $? -ne 1 ]; then
    echo "SSH Connection to GitHub failed with RC $?"
    return 4
fi

# Push to remote repos
git push --all  git@github.com:${github_owner}/${REPO_NAME}
git push --tags git@github.com:${github_owner}/${REPO_NAME}

return 0