#!/bin/bash

# Build website for repo
if   [ ! -d $site_dir ]; then
    echo "Error: Directory for sites does not exist: '$site_dir'"
    return 4
fi

function html_header() {

  if [ -n "$1" ]; then
    title=$1
  fi

  if [ -n "$2" ]; then
    depth=$2
  else
    depth=2
  fi

  uppath=$(for i in $(seq $depth); do echo -n "../";done)
  if [[ -z $uppath ]]; then
    uppath="./"
  fi

  echo "<html><head>"
  echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=2\" />"
  echo "<title>${title}</title>"
  echo "<link rel=\"stylesheet\" href=\"${uppath}_assets/css/dit.css\">"
  echo "<link rel=\"stylesheet\" href=\"${uppath}_assets/css/bulma.min.css\">"
  #echo "<link rel=\"stylesheet\" href=\"${uppath}_assets//highlight-default.css\">"
  #echo "<script src=\"${uppath}_assets/js/jquery-3.1.1.min.js\" defer=\"defer\"></script>"
  #echo "<script src=\"${uppath}_assets/js/bootstrap.min.js\" defer=\"defer\"></script>"
  #echo "<script src=\"${uppath}_assets/js/highlight.min.js\" defer=\"defer\"></script>"
  echo "<script src=\"${uppath}_assets/js/dit.js\" defer=\"defer\"></script>"

  echo "</head>"
  echo "<body>"

  echo "<section class=\"hero\">
         <div class=\"hero-body\">
           <p class=\"title\">$title</p>
         </div>
       </section>"

  if [[ "$depth" -gt 0 ]]; then

    echo -n "<nav class=\"navbar\" role=\"navigation\" aria-label=\"main navigation\"><div class=\"navbar-menu\">"
    echo -n "<a class=\"navbar-item\" href=\"${uppath}\">&lt;</a>"
    echo -n "<a class=\"navbar-item\" href=\"${uppath}${REPO_NAME}/commit/\">Log</a>"
    echo -n "<a class=\"navbar-item\" href=\"${uppath}${REPO_NAME}/branch/\">Branches</a>"
    echo -n "<a class=\"navbar-item\" href=\"${uppath}${REPO_NAME}/tag/\">Tag</a>"
    echo -n "<a class=\"navbar-item\" href=\"${uppath}${REPO_NAME}/file/\">Files</a>"
    echo "</div></nav>"
    #echo "<a href=\"../graph.html\">Graph</a>"

  fi

  echo "<pre>"

}

function html_footer() {

  if   [[ "$1" != "0" ]]; then
    echo "</pre><footer class=\"footer\">
            <div class=\"content has-text-centered\"><p><strong>$repo_project_title</strong> $repo_description</p>"
              if   [ -n "$site_clone_url" ]; then
                echo "<p><code>git clone $site_clone_url/$REPO_NAME.git</code></p>"
              fi
            echo "</div>
          </footer></body></html>"
    fi
}


# create sub directories if not already there
if   [ ! -d $site_dir/$REPO_NAME ]; then
  mkdir -v $site_dir/$REPO_NAME
fi

for dir in "commit" "branch" "tag" "file" "raw"; do
  if   [ ! -d $site_dir/$REPO_NAME/$dir ]; then
    mkdir -v $site_dir/$REPO_NAME/$dir
  fi
done

git archive HEAD | tar -x -C $site_dir/$REPO_NAME/raw
git archive --format tar.gz --output=$site_dir/$REPO_NAME/$REPO_NAME-latest.tar.gz HEAD


( html_header "$REPO_NAME" 1
  echo "$REPO_NAME"
  echo "$repo_project_title $repo_project_description"
  echo "<hr>"
  echo

  if   [ -f $site_dir/$REPO_NAME/raw/README.txt ]; then
    cat $site_dir/$REPO_NAME/raw/README.txt
  elif [ -f $site_dir/$REPO_NAME/raw/README.md ]; then
    cat $site_dir/$REPO_NAME/raw/README.md
  fi

  echo -n "Last Commit:"
  git log -1 --pretty=format:"%ad %an%x09<cite>%s</cite>" --date=rfc | tr -d '\n'
  echo "<hr>"

  echo -n "<a href=\"./commit/\">"
  git log --oneline | wc -l | tr -d '\n'
  echo -n " Commits"
  echo "</a>"

  echo -n "<a href=\"./tag/\">"
  git tag | wc -l | tr -d '\n'
  echo -n " Tags"
  echo "</a>"

  echo -n "<a href=\"./branch/\">"
  git branch | wc -l | tr -d '\n'
  echo -n " Branches"
  echo "</a>"

  echo -n "<a href=\"./file/\">"
  git ls-tree -r HEAD --name-only | wc -l | tr -d '\n'
  echo -n " Files"
  echo "</a>"

  echo "<hr>"
  echo "<a href=\"./$REPO_NAME-latest.tar.gz\">Download</a>"
  html_footer ) > $site_dir/$REPO_NAME/index.html

echo "Creating commit history"
( html_header "Log" 2

  git log --pretty=format:"%H%x09%ad%x09%an%x09%s" --date=rfc | while read line; do
    IFS=$'\t'; logline=($line); unset IFS;
    echo "<time>${logline[1]}</time> <em> ${logline[2]}</em> <a href=\"./${logline[0]}.html\"><cite>${logline[3]}</cite></a>"
  done
  html_footer ) > $site_dir/$REPO_NAME/commit/index.html

#( html_header "Graph"
#  git log --oneline --graph
#  html_footer ) > $site_dir/$REPO_NAME/graph.html

git log --pretty=%H | while read hash; do
  if [ ! -f $site_dir/$REPO_NAME/commit/$hash.html ]; then
    ( html_header "Commit" 2
      git log -1 $hash --stat
      html_footer ) > $site_dir/$REPO_NAME/commit/$hash.html;
  fi
done

echo "Creating branches"
( html_header "Branches" 2
  git branch --format='%(refname:short)'| while read line ; do echo "<a href=\"./$line.html\">$line</a>"; done
  html_footer ) > $site_dir/$REPO_NAME/branch/index.html;


git branch --format='%(refname:short)'| while read ref; do
  git archive --format tar.gz --output=$site_dir/$REPO_NAME/branch/$REPO_NAME-$ref.tar.gz $ref
( html_header "Branch <code>$ref</code>" 2
  echo "<a href=\"./$REPO_NAME-$ref.tar.gz\">Download $ref</a>"
  echo
  git ls-tree -r $ref --name-only
  html_footer ) > $site_dir/$REPO_NAME/branch/$ref.html;
done

echo "Creating tags"
( html_header "Tags" 2
  git tag| while read line ; do echo "<a href=\"./$line.html\">$line</a>"; done
  html_footer ) > $site_dir/$REPO_NAME/tag/index.html;

git tag | while read ref; do
  if   [ ! -f $site_dir/$REPO_NAME/tag/$REPO_NAME-$ref.tar.gz ]; then
    git archive --format tar.gz --output=$site_dir/$REPO_NAME/tag/$REPO_NAME-$ref.tar.gz $ref
  ( html_header "Tag <code>$ref</code>" 2
    echo "<a href=\"./$REPO_NAME-$ref.tar.gz\">Download Tag $ref</a>"
    echo
    git ls-tree -r $ref --name-only
    html_footer ) > $site_dir/$REPO_NAME/tag/$ref.html;
  fi
done

echo "Creating file list"
( html_header "Files" 2;
  echo "All files in HEAD:"
  git ls-tree -r HEAD --name-only | while read line ; do
    # experiment for tree
    #out=`echo $line | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"`
    out=$line
    echo "<a href=\"./content/$line.html\">$out</a>"
  done
  echo "<hr>"
  echo "<a href=\"../$REPO_NAME-latest.tar.gz\">Download</a>"
  html_footer )  > $site_dir/$REPO_NAME/file/index.html;

echo "Creating file information"
git ls-tree -r HEAD --name-only | while read f; do

filedirname=$(dirname $f )
mkdir -p "$site_dir/$REPO_NAME/file/content/${filedirname}"

slashes=${f//[^\/]}
depth=$(expr ${#slashes} + 3)
( html_header "File <code>$f</code>" "${depth}"
  echo -n "Last commit: "
  git log -1 --oneline --pretty=format:"%ad%x09%an%x09%s" -- $f
  echo "<hr>"

  uppath=$(for i in $(seq $depth); do echo -n "../";done)
  if [[ -z $uppath ]]; then
    uppath="./"
  fi

  type=$(file -b --mime-type $site_dir/$REPO_NAME/raw/$f| cut -d/ -f1)
  if   [ "$type" == "image" ]; then
    echo "<img src=\"${uppath}${REPO_NAME}/raw/$f\" />"
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
    echo "<i class=\"notification\">Binary file could not be displayed</i>"
  fi

  echo "<hr>"
  echo "<a href=\"${uppath}${REPO_NAME}/raw/$f\">Download <code>$f</code></a>"
  echo "<hr>"
  echo "History"
  git log --oneline --pretty=format:"%ad%x09%an%x09%s" --date=rfc -- $f
  html_footer ) > $site_dir/$REPO_NAME/file/content/${f}.html;
done
echo "done"

# Copy assets like CSS,JS,...

if   [ ! -d $site_dir/_assets ]; then
  mkdir -v $site_dir/_assets
fi

cp -r $DIT_DIR/assets/* $site_dir/_assets/

# Creating Index
if   ( is_on $site_index_create ); then
  echo "Creating index in $site_dir"
  ( html_header "$site_index_title" 0
  ( cd $site_dir; find . -maxdepth 1 -type d -printf '<a href="./%P">%P</a>\n'|sort )
  html_footer 0 ) > $site_dir/index.html
fi

if  [ -n "$site_sync_ssh_host" ]; then
  echo "Syncing to $site_sync_ssh_host ..."
  rsync -a --delete -e ssh $site_dir/ $site_sync_ssh_user@$site_sync_ssh_host:$site_sync_ssh_path
fi


