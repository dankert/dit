#!/bin/bash

DIT_DIR="$(dirname $0)/../"
MODULES_DIR="$(dirname $0)/modules"
STATUS="SUCCESS"

if   [ ! -d ./.git ]; then
  echo "No .git directory found" 1>&2;
  exit 4
fi

source "${DIT_DIR}/bin/lib.sh"


# reading config files
for configfile in /etc/.config/dit $HOME/.config/dit; do
  if   [ -f $configfile ]; then
    source $configfile
    echo "Read config from $configfile" >> $TMPFILE
  fi
done

if   is_on $notify; then
  TMPFILE=$(mktemp)
else
  TMPFILE=/dev/stdout
fi

# if git commits are present
if   [ $(git rev-list --count --all) != "0" ]; then
  LAST_COMMIT_USER=$(git log -n 1 --pretty=format:%an)
  LAST_COMMIT_EMAIL=$(git log -n 1 --pretty=format:%ae)
  LAST_COMMIT_MESSAGE=$(git log -n 1 --pretty=format:%B)
  LAST_COMMIT_DATE=$(git log -n 1 --pretty=format:%cD)
fi

USER_NAME=$(git config --get user.name)
USER_EMAIL=$(git config --get user.email)

REPO=${PWD}
REPO_NAME="$(basename $REPO)"

echo >> $TMPFILE
echo "----------------------------------------------------------------------------" >> $TMPFILE
echo "Building $REPO_NAME" >> $TMPFILE
echo "----------------------------------------------------------------------------" >> $TMPFILE
echo "Starting at: $(date -R)" >> $TMPFILE
echo "Project home: $REPO" >> $TMPFILE
echo "----------------------------------------------------------------------------" >> $TMPFILE

PROJECT_CONFIG_FILE=$REPO/.dit.yml

echo >> $TMPFILE
echo "--- Prepare ---" >> $TMPFILE

if  [ -f $PROJECT_CONFIG_FILE ]; then
  #parse_yaml $PROJECT_CONFIG_FILE "repo_" >> $TMPFILE
  eval $(parse_yaml $PROJECT_CONFIG_FILE "repo_")
else
  echo "No file $PROJECT_CONFIG_FILE found - ignoring..." >> $TMPFILE
fi
set | grep -i "^repo" >> $TMPFILE


for module in $MODULES_DIR/*; do

  filename=$(basename -- "$module")
  extension="${filename##*.}"
  modulename="${filename%.*}"

  echo >> $TMPFILE
  echo "--- Module $modulename ---" >> $TMPFILE
  if   is_on ${!modulename}; then
    source $module 2>> $TMPFILE >> $TMPFILE
    if [ $? -ne 0 ]; then
        echo "*** Module $modulename FAILED ***" >> $TMPFILE
        STATUS="$modulename FAILED"
        cat $TMPFILE
        break
    fi
  else
    echo "Module is disabled" >> $TMPFILE
  fi
  echo >> $TMPFILE

done

echo >> $TMPFILE
echo "----------------------------------------------------------------------------" >> $TMPFILE
echo "$STATUS" >> $TMPFILE
echo "----------------------------------------------------------------------------" >> $TMPFILE
echo >> $TMPFILE
echo "Finished at: $(date -R)" >> $TMPFILE
echo "Powered by DIT $(dirname $0)" >> $TMPFILE
echo "----------------------------------------------------------------------------" >> $TMPFILE

if   is_on $notify; then
  notify
  if [ $? -ne 0 ]; then
      echo "Notify FAILED" 1>&2
      exit 4
  fi

  rm $TMPFILE
fi

