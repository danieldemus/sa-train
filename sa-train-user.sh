#!/usr/bin/bash
shopt -s extglob

if [[ -r /etc/sa-train.conf ]]; then
    while read -r name value; do
        if [[ -n "$name" && ! "$name" =~ ^\s*# ]]; then
          typeset "$name=$value"
        fi
    done < /etc/sa-train.conf
fi

if [[ -r  ~/.sa-train/config ]]; then
    while read -r name value; do
        if [[ -n "$name" && ! "$name" =~ ^\s*# ]]; then
          typeset "$name=$value"
        fi
    done < ~/.sa-train/config
fi

SPAMFOLDER=${spam_folder:-Spam}
typeset -i "MAX_AGE=${max_age:-90}"

function examine
{
  local subdir=$1
  if [[ -n "$subdir" && "$subdir" == "${subdir%/}" ]]; then
    subdir="$subdir/"
  fi
  if [[ ! -d ./${subdir}cur ]]; then
    return
  fi

  local action=${2:-ham}
  
  echo Learning from ${subdir:-Inbox} as $action
  pushd ${subdir}cur
  if [[ -f ~/.sa-train/last$1 ]]; then
    find -H . -type f -regex ".*:2,[a-zA-Z]*S[a-zA-Z]*$" -newer ~/.sa-train/last$1 -exec sa-learn --$action --no-sync {} \+;
  else
    find . -type f -regex ".*:2,[a-zA-Z]*S[a-zA-Z]*$" -mtime -$MAX_AGE -exec sa-learn --$action --no-sync {} \+;
  fi
  rm -f ~/.sa-train/last$1

  if [[ $( ls *\:2,*([a-zA-Z])S*([a-zA-Z]) 2>/dev/null ) ]]; then
    ln -s $( realpath $( ls -1t *\:2,*([a-zA-Z])S*([a-zA-Z]) | head -1) ) ~/.sa-train/last$1;
  fi
  popd
}


if [ -d ~/Maildir ]; then
  mkdir -p ~/.sa-train
  pushd ~/Maildir

  examine .$SPAMFOLDER spam
  examine
  examine .Root
  for inboxdir in ./.INBOX*; do
    examine $(basename $inboxdir);
  done;
  
  echo sa-learn --sync
  
  popd
fi
