#!/bin/bash


MODULES_DIR="$(dirname $0)/modules"

for module in $MODULES_DIR/*; do

  filename=$(basename -- "$module")
  extension="${filename##*.}"
  modulename="${filename%.*}"

  echo 
  echo "----------------------------------------------------------------------------"
  echo "Module $modulename"
  echo "----------------------------------------------------------------------------"
  if   is_on "${!modulename}"; then
    repomodulename="repo_modules_${modulename}"
    if   is_on "${!repomodulename}"; then
      source $module 2
      if [ $? -ne 0 ]; then
          echo "*** Module $modulename FAILED ***"
          return 4
      fi
      echo "Module $modulename suceeded"
    else
      echo "Module is disabled by this project"
    fi
  else
    echo "Module is disabled"
  fi
  echo 

done
