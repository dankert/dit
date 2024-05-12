#!/bin/bash

# Build website for repo
if   [ ! -d $site_dir ]; then
    echo "Directory does not exist: $site_dir"
    return 4
fi

function html_header() {

  if [ -n "$1" ]; then
    title=$1
  else
    title=$site_index_title
  fi
  echo "<html><head>"
  echo "<title>${title}</title>"
  echo "<link rel=\"stylesheet\" href=\"../css/bootstrap.min.css\">"
  echo "<link rel=\"stylesheet\" href=\"../css/bootstrap-theme.min.css\">"
  echo "<link rel=\"stylesheet\" href=\"../css/highlight-default.css\">"
  echo "<script src=\"../js/jquery-3.1.1.min.js\" defer=\"defer\"></script>"
  echo "<script src=\"../js/bootstrap.min.js\" defer=\"defer\"></script>"
  echo "<script src=\"../js/highlight.min.js\" defer=\"defer\"></script>"
  echo "<script src=\"../js/dit.js\" defer=\"defer\"></script>"

  echo "</head>"
  echo "<body>"
  echo "<h1>${title}</h1>"

  if [ -n "$1" ]; then
    echo "<a href=\"../\">&lt;</a>"
    echo "<a href=\"../commit/\">Log</a>"
    echo "<a href=\"../branch/\">Branches</a>"
    echo "<a href=\"../tag/\">Tag</a>"
    echo "<a href=\"../file/\">Files</a>"
    #echo "<a href=\"../graph.html\">Graph</a>"
    if   [ -n "$site_clone_url" ]; then
      echo "<code>git clone $site_clone_url/$REPO_NAME.git</code>"
    fi
  fi

  echo "<pre>"

}

function html_footer() {

  echo "</body></html></pre>"
}


# create sub directories if not already there
for dir in "commit" "branch" "tag" "file" "raw"; do
  if   [ ! -d $site_dir/$REPO_NAME/$dir ]; then
    mkdir -v $site_dir/$REPO_NAME/$dir
  fi
done


( html_header
  echo "$REPO_NAME"
  echo "$repo_name $repo_description"
  echo
  echo "Last Commit:"
  git log -1 --pretty=format:"%ad %an%x09<cite>%s</cite>" --date=rfc
  echo "<hr>"

  echo "<a href=\"./commit/\">"
  git log --oneline | wc -l
  echo " Commits"
  echo "</a>"

  echo "<a href=\"./tag/\">"
  git tag | wc -l
  echo " Tags"
  echo "</a>"

  echo "<a href=\"./branch/\">"
  git branch | wc -l
  echo " Branches"
  echo "</a>"

  echo "<a href=\"./file/\">"
  git ls-files | wc -l
  echo " Files"
  echo "</a>"

  echo "<hr>"
  echo "<a href=\"./$REPO_NAME-latest.tar.gz\">Download</a>"
  html_footer ) > $site_dir/$REPO_NAME/index.html

echo "Creating commit history"
( html_header "Log"

  git log --pretty=format:"%H%x09%ad%x09%an%x09%s" --date=rfc | while read line; do
    IFS=$'\t'; logline=($line); unset IFS;
    echo "<time>${logline[1]}</time> <em> ${logline[2]}</em> <a href=\"./${logline[0]}.html\"><cite>${logline[3]}</cite></a>"
  done
  html_footer ) > $site_dir/$REPO_NAME/commit/index.html


git archive --format tar.gz --output=$site_dir/$REPO_NAME/$REPO_NAME-latest.tar.gz HEAD

#( html_header "Graph"
#  git log --oneline --graph
#  html_footer ) > $site_dir/$REPO_NAME/graph.html

git log --pretty=%H | while read hash; do
( html_header "Commit"
  git log -1 $hash --stat
  html_footer ) > $site_dir/$REPO_NAME/commit/$hash.html;
done

echo "Creating branches"
( html_header "Branches"
  git branch --format='%(refname:short)'| while read line ; do echo "<a href=\"./$line.html\">$line</a>"; done
  html_footer ) > $site_dir/$REPO_NAME/branch/index.html;


git branch --format='%(refname:short)'| while read ref; do
( html_header "Branch $ref"
  git ls-tree -r $ref --name-only
  html_footer ) > $site_dir/$REPO_NAME/branch/$ref.html;
done

echo "Creating tags"
( html_header "Tags"
  git tag| while read line ; do echo "<a href=\"./$line.html\">$line</a>"; done
  html_footer ) > $site_dir/$REPO_NAME/tag/index.html;

git tag | while read ref; do
( html_header "Tag $ref"
  git ls-tree -r $ref --name-only
  html_footer ) > $site_dir/$REPO_NAME/tag/$ref.html;
done

git archive HEAD | tar -x -C $site_dir/$REPO_NAME/raw

echo "Creating file information"
( html_header "Files";
  git ls-tree -r HEAD --name-only | while read line ; do
    hash=`git hash-object $line`;
    # experiment for tree
    #out=`echo $line | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"`
    out=$line
    echo "<a href=\"$hash.html\">$out</a>"
  done
  html_footer )  > $site_dir/$REPO_NAME/file/index.html;

git ls-tree -r HEAD --name-only | while read f; do
hash=`git hash-object $f`
( html_header "File $f";
  echo -n "Last commit: "
  git log -1 --oneline --pretty=format:"%ad%x09%an%x09%s" -- $f
  echo "<hr>"
  type=$(file -b --mime-type $site_dir/$REPO_NAME/raw/$f| cut -d/ -f1)
  if   [ "$type" == "image" ]; then
    echo "<img src=\"../raw/$f\" />"
  elif   [ "$type" == "text" ]; then
    extension="${f##*.}"
    echo "<code class=\"source\" data-language=\"$extension\">"
    # output with line numbers and HTML escaping
    num=0; # line number
    cat $site_dir/$REPO_NAME/raw/$f | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' | while IFS= read -r line  || [ -n "$line" ]; do
      ((++num)) # increase line number
      printf '%0.s ' $(seq 1 $((6-${#num}))) # right-align the line number
      echo "<a class=\"line\" id=\"$num\" href=\"#$num\">$num</a> $line"
    done
    echo "</code>"
  else
    echo "Download binary file: <a href=\"../raw/$f\" />"
  fi

  echo "<hr>"
  echo "<a href=\"../raw/$f\">Download</a>"
  echo "<hr>"
  echo "History"
  git log --oneline --pretty=format:"%ad%x09%an%x09%s" --date=rfc -- $f
  html_footer ) > $site_dir/$REPO_NAME/file/$hash.html;
done


# Copy assets like CSS,JS,...
cp -r $DIT_DIR/assets/* $site_dir/$REPO_NAME

# Creating Index
if   ( is_on $site_index_create ); then
  echo "Creating index in $site_dir"
  ( html_header
  ( cd $site_dir; find . -maxdepth 1 -type d -printf '<a href="./%P">%P</a>\n' )
  html_footer ) > $site_dir/index.html
fi

if  [ -n "$site_sync_ssh_host" ]; then
  echo "Syncing to $site_sync_ssh_host ..."
  rsync -a -e ssh $site_dir/ $site_sync_ssh_user@$site_sync_ssh_host:$site_sync_ssh_path
fi


