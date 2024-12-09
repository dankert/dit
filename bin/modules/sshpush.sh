#!/bin/bash

echo "Pushing repository '$REPO_NAME' to '${ssh_host}'"

# no commits? No action.
if   [ $(git rev-list --count --all) == "0" ]; then
  echo "Warning: There are no commits in this repository, unable to push"
  return 0
fi

# Check if remote repo exists
if (ssh ${ssh_user}@${ssh_host} "[ ! -d ${ssh_path}/${REPO_NAME}.git ]"); then
 echo "Repository does not exist. Creating a new remote bare repository ..."
 ssh ${ssh_user}@${ssh_host} "mkdir ${ssh_path}/${REPO_NAME}.git;cd ${ssh_path}/${REPO_NAME}.git; git init --bare"
fi

# Push to remote repos
echo "Pushing to remote repository as user '${ssh_user}' to '${ssh_host}:${ssh_path}/${REPO_NAME}'"
git push --all  ${ssh_user}@${ssh_host}:${ssh_path}/${REPO_NAME}
git push --tags ${ssh_user}@${ssh_host}:${ssh_path}/${REPO_NAME}

# Updating serverinfo for HTTP pulls
echo "Updating serverinfo ..."
ssh ${ssh_user}@${ssh_host} "cd ${ssh_path}/${REPO_NAME}.git; git update-server-info"
