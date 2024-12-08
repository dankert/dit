#!/bin/bash

DIT_DIR="$(dirname $0)/../"

source "${DIT_DIR}/bin/lib.sh"


# reading config files
for configfile in ${DIT_DIR}/config/config-default.sh /etc/.config/dit /etc/dit /etc/.config/dit $HOME/.config/dit; do
  if   [ -f $configfile ]; then
    #echo "Read config from $configfile"
    source $configfile
  else
    :
    #echo "Not found: $configfile"
  fi
done

if  is_on $notify; then
  TMPFILE=$(mktemp)
else
  TMPFILE=/dev/stdout
fi

git log HEAD..HEAD
if [ $? -ne 0 ]; then
    echo "Error: No GIT repository found in $(pwd)"
    echo "Seems like this is no GIT repo."
    echo "Try to use 'git init' to create a GIT repository here."
    exit 4
fi

source ${DIT_DIR}/bin/build.sh >> $TMPFILE 2>&1

if   is_on $notify; then
  notify
  if [ $? -ne 0 ]; then
      echo "Notify FAILED" 1>&2

      echo "Log output:"
      echo $TMPFILE
      exit 4
  fi

  rm $TMPFILE
else
  :  # NOP
fi

