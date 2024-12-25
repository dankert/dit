#!/bin/bash

function build() {


  TAG=$1

  if   [ -z "$TAG" ]; then
    echo "Error: No tag defined..."
    return
  fi

  if   [ ! -f ${WORK_DIR}/Dockerfile ]; then
    echo "Info: No Dockerfile for tag $TAG, continueing ..."
    return
  fi
  tagname="$REPO_NAME:$1"
  echo
  echo "--- Building Docker image $tagname ---"
  docker build $WORK_DIR --tag $tagname

  if [ $? -ne 0 ]; then
      echo
      echo "Error: Docker build FAILED"
      return 4
  fi

  if   [ -n "$dockerhub_owner" ]; then
    echo
    echo ">>>>>>>>> Pushing $tagname to remote"
    tagname_remote="$dockerhub_owner/$tagname"
    docker image tag $tagname $tagname_remote

    docker push $tagname_remote

    if [ $? -ne 0 ]; then
        echo "Error: Docker push FAILED"
        return 4
    fi
  else
    echo "Info: No dockerhub user configured, so not pushing to dockerhub"
  fi
}

WORK_DIR="$(mktemp -d)"

echo "Cloning GIT to temporary directory $WORK_DIR ..."
git clone . $WORK_DIR

build latest

echo "Searching for GIT tags ..."
git -C $WORK_DIR tag
for tag in $(git -C $WORK_DIR tag); do
  echo "... found tag $tag"

  if   [[ $(docker images -q $REPO_NAME:$tag | wc -c) -ne 0 ]]; then
    echo "Info: Image $REPO_NAME:$tag found"
  else
    echo "Info: Image $REPO_NAME:$tag not found in local registry"
    git -C $WORK_DIR checkout tags/$tag
    build $tag
    if   [ $? -ne 0 ]; then
      echo "Error: Image could not be build."
      return 4;
    fi
  fi
done

echo "Deleting $WORK_DIR"
rm -rf $WORK_DIR