#!/bin/bash

# Build website for repo
if   [ ! -d $public_dir ]; then
    echo "Directory does not exist: $public_dir"
    return 4
fi

mkdir -p $public_dir/$REPO_NAME
git archive HEAD | tar -x -C $public_dir/$REPO_NAME


# Creating Index
if   ( is_on $public_index_create ); then
  echo "Creating index in $public_dir"
  ( echo "<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=2\" /></head><body><pre>"
  ( cd $public_dir; find . -maxdepth 1 -type d -printf '<a href="./%P">%P</a>\n' )
  echo "</pre></body></html>" ) > $public_dir/index.html
fi

# Creating HTML from MD
if   ( is_on $public_markdown_to_html ); then
  ( cd $public_dir; find . -type f -name "*.md" -exec pandoc -f markdown -t html -o {}.html {} \; )
fi

if  [ -n "$public_sync_ssh_host" ]; then
  echo "Syncing to $public_sync_ssh_host ..."
  rsync -a --delete -e ssh $public_dir/ $public_sync_ssh_user@$public_sync_ssh_host:$public_sync_ssh_path 2>&1
fi


