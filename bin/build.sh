#!/bin/bash

echo
echo "--- Prepare ---"

if   is_on ${debug}; then echo "Debug is enabled"; fi

PRJCONFFILE=$(mktemp)
git archive HEAD ${project_config_file}|tar xO > $PRJCONFFILE
if  [ $? -eq 0 ]; then
  echo "Reading per project config '${project_config_file}' from '$PRJCONFFILE'"

  if   is_on ${debug}; then
    echo $PRJCONFFILE
    echo "Content of '${project_config_file}':"
    echo $(parse_yaml $PRJCONFFILE "repo_")
  fi;
  eval $(parse_yaml $PRJCONFFILE "repo_")
else
  echo "No file $project_config_file found - ignoring..."
fi
rm $PRJCONFFILE

if   is_on ${debug}; then
  set | grep -i "^repo"
fi;

REPO=${PWD}
echo "Repository directory: $REPO"
# GIT has no specific repository name, so we are using the directory name
REPO_NAME="$(basename $REPO| cut -d'.' -f1)"
echo "Repository bare name: $REPO_NAME"
# ... but it is possible to overwrite it
if   [ -n "$repo_project_name" ]; then REPO_NAME=$repo_project_name; fi
# clear unwanted chars for safe file operations
REPO_NAME="$(echo -n $REPO_NAME| tr '[:upper:]' '[:lower:]'|tr -c '[:alnum:]' '-')"

# Fallback values for repo information...
if   [ -z "$repo_project_title"       ]; then repo_project_title=$REPO_NAME; fi
if   [ -z "$repo_project_description" ]; then repo_project_description="" ; fi
if   [ -z "$repo_project_author"      ]; then repo_project_author=$(git log -1 --pretty=format:'%an') ; fi
if   [ -z "$repo_project_email"       ]; then repo_project_author=$(git log -1 --pretty=format:'%ae') ; fi

echo "Repository name     : $REPO_NAME"
echo "Repository title    : $repo_project_title"
echo "Repository descr.   : $repo_project_description"
echo "Repository author   : $repo_project_author"
echo "Repository email    : $repo_project_email"
echo
echo "----------------------------------------------------------------------------" 
echo "BUILDING $REPO_NAME"
echo "----------------------------------------------------------------------------"
echo "Starting at: $(date -R)"
echo "Project home: $REPO" 
echo "----------------------------------------------------------------------------" 


# if git commits are present
if   [ $(git rev-list --count --all) != "0" ]; then
  LAST_COMMIT_USER=$(git log -n 1 --pretty=format:%an)
  LAST_COMMIT_EMAIL=$(git log -n 1 --pretty=format:%ae)
  LAST_COMMIT_MESSAGE=$(git log -n 1 --pretty=format:%B)
  LAST_COMMIT_DATE=$(git log -n 1 --pretty=format:%cD)
fi

USER_NAME=$(git config --get user.name)
USER_EMAIL=$(git config --get user.email)

source ${DIT_DIR}/bin/modules.sh

if [ $? -eq 0 ]; then
   STATUS="SUCCESS"
else
   STATUS="FAILED"
fi

echo
echo "----------------------------------------------------------------------------"
echo "BUILD $STATUS"
echo "----------------------------------------------------------------------------"
echo
echo "Finished at: $(date -R)"
echo "Powered by DIT $(dirname $0)"
echo "----------------------------------------------------------------------------"