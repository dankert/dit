#!/bin/bash

echo "Pushing repository '$REPO_NAME' to '${ssh_host}'"

if   [ $(git rev-list --count --all) == "0" ]; then
  echo "Warning: There are no commits in this repository, unable to push"
  return 0
fi

# Remote
if (ssh dankert@weiherhei.de "[ ! -d ${ssh_path}/${REPO_NAME}.git ]"); then
 echo "creating remote bare repository"
 ssh dankert@weiherhei.de "mkdir ${ssh_path}/${REPO_NAME}.git;cd ${ssh_path}/${REPO_NAME}.git; git init --bare"
fi

# Push to remote repos
git push --all  ${ssh_user}@${ssh_host}:${ssh_path}/${REPO_NAME}
git push --tags ${ssh_user}@${ssh_host}:${ssh_path}/${REPO_NAME}
ssh ${ssh_user}@${ssh_host} "cd ${ssh_path}/${REPO_NAME}.git; git update-server-info"
