#!/bin/bash

if  [ ! -d $archive_dir ]; then
    echo "$archive_dir does not exist"
    return 4
fi

if  [ ! -d $archive_dir/$REPO_NAME ]; then
    mkdir $archive_dir/$REPO_NAME
    if [ $? -ne 0 ]; then
        echo "mkdir of $archive_dir/$REPO_NAME FAILED"
        return 4
    fi
fi

if   [ $(git rev-list --count --all) == "0" ]; then
  echo "There are no commits in this repository. Nothing to do."
  return 0
fi

echo "archiving latest..."

if [ $? -ne 0 ]; then
    echo "archive FAILED"
    return 4
fi

outfile="$archive_dir/$REPO_NAME/$REPO_NAME-latest.tar.gz"
git archive --format tar.gz --output=$outfile HEAD

files=()
files+=($outfile)

if [ $? -ne 0 ]; then
    echo "archive FAILED"
    return 4
fi

echo "Searching for git tags..."
for tag in `git tag`; do
  echo "... found tag $tag"
  archive_file=$archive_dir/$REPO_NAME/$REPO_NAME-$tag.tar.gz
  files+=($archive_file)
  if   [ ! -f $archive_file ]; then
    git archive --format tar.gz --output=$archive_file $tag
    if [ $? -ne 0 ]; then
        echo "Archive FAILED"
        return 4
    fi

  fi
done

(
  echo "<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=2\" /></head><body><pre>";
  for f in $files; do
    filenam="$(basename $f)"
    echo "<a href=\"./$filenam\">$filenam</a>";
  done
  echo "</pre></body></html>"
) > $archive_dir/$REPO_NAME/index.html

(
  echo "<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=2\" /></head><body><pre>";
  ( cd $archive_dir; find . -type d -printf '<a href="./%P">%P</a>\n');
  echo "</pre></body></html>"
) > $archive_dir/index.html

echo "Syncing to $archive_ssh_host ..."
rsync -av -e ssh $archive_dir/  $archive_ssh_user@$archive_ssh_host:$archive_ssh_path