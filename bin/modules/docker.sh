#!/bin/bash

function build() {


  TAG=$1

  if   [ -z "$TAG" ]; then
    echo "No tag defined..." 1>&2;
    return
  fi

  if   [ ! -f ./Dockerfile ]; then
    echo "No Dockerfile for tag $TAG, continueing ..." 1>&2;
    return
  fi
  tagname="$REPO_NAME:$1"
  tagname_remote="$docker_owner/$tagname"
  echo "--- Building Docker image $tagname ---"
  docker build $WORK_DIR --tag $tagname

  if [ $? -ne 0 ]; then
      echo
      echo "Docker build FAILED"
      return 4
  fi

  echo ">>> Pushing $tagname to remote"
  docker image tag $tagname $tagname_remote

  docker push $tagname_remote

  if [ $? -ne 0 ]; then
      echo
      echo "Docker push FAILED"
      return 4
  fi
}

WORK_DIR="$(mktemp -d)"

git clone . $WORK_DIR

build latest >> $TMPFILE

echo "Searching for git tags..."
for tag in `git -C $WORK_DIR tag`; do
  echo "... found tag $tag"

  ALREADY_THERE=`docker manifest inspect $IMGNAME:$IMGTAG > /dev/null ; echo $?`
  if   [ $ALREADY_THERE ]; then
    git -C $WORK_DIR checkout tags/$tag
    build $tag >> $TMPFILE
  fi
done

rm -rf $WORK_DIR