#!/bin/bash

echo "Pushing git repo to GitHub"

curl --fail --silent https://github.com/${github_owner}/${REPO_NAME} > /dev/null

# Checking if repo exists on github.
if [ $? -ne 0 ]; then
    echo "Warning: GitHub-Project ${REPO_NAME} does not exist"
    if [ -n "$github_access_token" ]; then
      echo "GitHub-Repo will be created..."
      curl  -H "Authorization: token $github_access_token" \
             -d "{ \"name\": \"${REPO_NAME}\" ,
                  \"auto_init\": false ,
                  \"private\": false,
                  \"has_issues\": false,
                  \"has_wiki\": false,
                  \"has_downloads\": false,
                }" https://api.github.com/user/repos
    else
      echo "Warning: No Github-token configured, so it is not possible to create a new repository at Github."
      echo "         Go to https://github.com/new to create the repo '$REPO_NAME'."
      return # no project on github, exiting without error
    fi
fi


if [ -n "$github_access_token" ]; then
  echo "Updating repository description at Github ..."
  curl  -H "Authorization: token $github_access_token" \
         -d "{ \"description\": \"${repo_project_description}\"
            }" https://api.github.com/repos/${github_owner}/${REPO_NAME}
fi

ssh -q git@github.com

if [ $? -ne 1 ]; then
    echo "Warning: SSH Connection to GitHub failed with RC $?"
    echo "         Maybe there is no SSH Key for Github"
    return 4
fi

# Push to remote repos
git push -vv --all  git@github.com:${github_owner}/${REPO_NAME}
if [ $? -ne 0 ]; then
    echo "Error: Push to github failed due to exitcode $?"
    return 4
fi

git push -vv --tags git@github.com:${github_owner}/${REPO_NAME}
if [ $? -ne 0 ]; then
    echo "Error: Push to github failed due to exitcode $?"
    return 4
fi

return 0