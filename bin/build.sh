#!/bin/bash

REPO=${PWD}
REPO_NAME="$(basename $REPO)"

# Fallback values for repo name and description.
if   [ -z $repo_name        ]; then repo_name=$REPO_NAME; fi
if   [ -z $repo_description ]; then repo_description="" ; fi

echo
echo "----------------------------------------------------------------------------" 
echo "BUILDING $REPO_NAME"
echo "----------------------------------------------------------------------------" 
echo "Starting at: $(date -R)" 
echo "Project home: $REPO" 
echo "----------------------------------------------------------------------------" 

echo
echo "--- Prepare ---" 

# if git commits are present
if   [ $(git rev-list --count --all) != "0" ]; then
  LAST_COMMIT_USER=$(git log -n 1 --pretty=format:%an)
  LAST_COMMIT_EMAIL=$(git log -n 1 --pretty=format:%ae)
  LAST_COMMIT_MESSAGE=$(git log -n 1 --pretty=format:%B)
  LAST_COMMIT_DATE=$(git log -n 1 --pretty=format:%cD)
fi

USER_NAME=$(git config --get user.name)
USER_EMAIL=$(git config --get user.email)


#if is_on $debug; then
#  echo parse_yaml $project_config_file;
#end;

if  [ -f "$project_config_file" ]; then
  echo "reading per project config from '$project_config_file'"
  #echo $(parse_yaml $project_config_file "repo_")
  #eval $(parse_yaml $project_config_file "repo_")
else
  echo "No file $project_config_file found - ignoring..."
fi

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