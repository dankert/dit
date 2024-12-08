#!/bin/bash

function build() {


  TAG=$1

  if   [ -z "$TAG" ]; then
    echo "No tag defined..."
    return
  fi

  if   [ ! -f ./Dockerfile ]; then
    echo "No Dockerfile for tag $TAG, continueing ..."
    return
  fi
  tagname="$REPO_NAME:$1"
  echo
  echo "--- Building Docker image $tagname ---"
  docker build $WORK_DIR --tag $tagname

  if [ $? -ne 0 ]; then
      echo
      echo "Docker build FAILED"
      return 4
  fi

  echo
  echo ">>>>>>>>> Pushing $tagname to remote"
  tagname_remote="$dockerhub_owner/$tagname"
  docker image tag $tagname $tagname_remote

  docker push $tagname_remote

  if [ $? -ne 0 ]; then
      echo "Docker push FAILED"
      return 4
  fi
}

WORK_DIR="$(mktemp -d)"

echo "Cloning GIT to temporary directory $WORK_DIR ..."
git clone . $WORK_DIR

build latest

echo "Searching for GIT tags ..."
for tag in `git -C $WORK_DIR tag`; do
  echo "... found tag $tag"

  if   [[ $(docker images -q $REPO_NAME:$tag | wc -c) -ne 0 ]]; then
    echo "Image $REPO_NAME:$tag is already there"
  else
    git -C $WORK_DIR checkout tags/$tag
    build $tag
  fi
done

echo "Deleting $WORK_DIR"
rm -rf $WORK_DIR