#!/bin/bash
shopt -s extglob

if [ -r /etc/sa-train.conf ]; then
    while read -r name value; do
        if [[ -n "$name" && ! "$name" =~ "$\w*#" ]]; then
          typeset "$name=$value"
        fi
    done < /etc/sa-train.conf
fi

if [ -r  ~/.sa-train/config ]; then
    while read -r name value; do
        if [[ -n "$name" && ! "$name" =~ "$\w*#" ]]; then
          typeset "$name=$value"
        fi
    done < ~/.sa-train/config
fi

local SPAMFOLDER=${spam_folder:-.Spam}
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
  
  echo Learning from $subdir as $action
  pushd ${subdir}cur
  if [[ -f ~/.sa-train/last$1 ]]; then
    find -H . -type f -regex ".*,[^,]*S[^,]*$" -newer ~/.sa-train/last$1 -exec sa-learn --$action --no-sync {} \+;
  else
    find . -type f -regex ".,[^,]*S[^,]*$" -mtime -$MAX_AGE -exec sa-learn --$action --no-sync {} \+;
  fi
  rm -f ~/.sa-train/last$1

  if [[ $( ls *,*([!,])S*([!,]) 2>/dev/null ) ]]; then
    ln -s $( realpath $( ls -1t *,*([!,])S*([!,]) | head -1) ) ~/.sa-train/last$1;
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
  
  sa-learn --sync
  
  popd
fi
