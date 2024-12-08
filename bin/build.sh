#!/bin/bash

REPO=${PWD}
REPO_NAME="$(basename $REPO| cut -d'.' -f1)"

# Fallback values for repo name and description.
if   [ -z $repo_project_name        ]; then repo_project_name=$REPO_NAME; fi
if   [ -z $repo_project_description ]; then repo_project_description="" ; fi
if   [ -z $repo_project_author      ]; then repo_project_author=$(git log -1 --pretty=format:'%an') ; fi
if   [ -z $repo_project_email       ]; then repo_project_author=$(git log -1 --pretty=format:'%ae') ; fi

echo
echo "----------------------------------------------------------------------------" 
echo "BUILDING $REPO_NAME"
echo "----------------------------------------------------------------------------" 
echo "Starting at: $(date -R)" 
echo "Project home: $REPO" 
echo "----------------------------------------------------------------------------" 

echo
echo "--- Prepare ---" 

if   is_on ${debug}; then echo "Debug is enabled"; fi

# if git commits are present
if   [ $(git rev-list --count --all) != "0" ]; then
  LAST_COMMIT_USER=$(git log -n 1 --pretty=format:%an)
  LAST_COMMIT_EMAIL=$(git log -n 1 --pretty=format:%ae)
  LAST_COMMIT_MESSAGE=$(git log -n 1 --pretty=format:%B)
  LAST_COMMIT_DATE=$(git log -n 1 --pretty=format:%cD)
fi

USER_NAME=$(git config --get user.name)
USER_EMAIL=$(git config --get user.email)


#  echo parse_yaml $project_config_file;
#end;
PRJCONFFILE=$(mktemp)
git archive HEAD ${project_config_file}|tar xO > $PRJCONFFILE
if  [ $? -eq 0 ]; then
  echo "reading per project config '${project_config_file}' from '$PRJCONFFILE'"

  if   is_on ${debug}; then
    echo $PRJCONFFILE
    echo ""
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