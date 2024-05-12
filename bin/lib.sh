#!/bin/bash

# is $1 a boolean true?
is_on() {
  if   [[ "$1" == "true" || "$1" == "1" || "$1" == "on" || "$1" == "enabled" ]]; then
    return 0; # RC 0 is "true" ;)
  else
    return 1 # 1 is != 0, means false ;)
  fi
}

comma_sep() {
  echo $1|xargs|sed "s/ /,/g"
}


# thx to Stefan Farestam
# source: https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function notify() {
  receiver_list=$(comma_sep "$notify_add_receiver_mail $repo_email $USER_EMAIL $LAST_COMMIT_EMAIL")

  if   is_on $notify_sendmail; then
    #echo "Sending mail to $1"
    printf "To: Jan\nSubject: %s\n\n%s" "Report for $REPO_NAME: $STATUS" "$(cat $TMPFILE)" | sendmail "$receiver_list"
    if [ $? -ne 0 ]; then
        cat $TMPFILE 1&2
        echo "Sending the mail FAILED" 1>&2
        return 4
    fi
   fi

  if   ( is_on $notify_smtp && [ -n "$notify_smtp_host" ] ); then
    curl --silent smtp://${notify_smtp_host} --mail-from "$notify_smtp_from" --mail-rcpt "${notify_add_receiver_mail}" \
      --header "Subject: Report for $REPO_NAME: $STATUS" \
      --header "X-Repo: $REPO_NAME" \
      $receiver_list --upload-file $TMPFILE
    if [ $? -ne 0 ]; then
        cat $TMPFILE 1>&2
        echo "Sending the mail via curl FAILED" 1>&2
        return 4
    fi
  fi

  if   is_on $notify_stdout; then
    echo "output:"
    cat $TMPFILE
  fi
}
