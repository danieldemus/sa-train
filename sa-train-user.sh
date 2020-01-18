#!/bin/bash
shopt -s extglob

while getopts u:d:p:f: option
do
case "${option}"
in
u) USER=${OPTARG};;
d) DATE=${OPTARG};;
p) PRODUCT=${OPTARG};;
f) FORMAT=${OPTARG};;
esac
done

function examine
{
  local subdir=$1
  if [[ -n "$subdir" ]]; then
    subdir="$subdir/"
  fi
  if [[  ! -d ./${subdir}cur ]]; then
    return
  fi

  local action=ham
  if [[ ! -z "$2" ]]; then
    action=$2
  fi
  
  echo Learning from $subdir as $action
  pushd ${subdir}cur
  if [[ -f ~/.sa-learn/last$1 ]]; then
    find -H . -type f -regex ".*,[^,]*S[^,]*$" -newer ~/.sa-learn/last$1 -exec sa-learn --$action --no-sync {} \+;
  else
    find . -type f -regex ".,[^,]*S[^,]*$" -mtime -30 -exec sa-learn --$action --no-sync {} \+;
  fi
  rm -f ~/.sa-learn/last$1

  if [[ $( ls *,*([!,])S*([!,]) 2>/dev/null ) ]]; then
    ln -s $( realpath $( ls -1t *,*([!,])S*([!,]) | head -1) ) ~/.sa-learn/last$1;
  fi
  popd
}


if [ -d ~/Maildir ]; then
  mkdir -p ~/.sa-learn
  pushd ~/Maildir

  examine .Spam spam
  examine
  examine .Root
  for inboxdir in ./.INBOX*; do
    examine $(basename $inboxdir);
  done;
  
  sa-learn --sync
  
  popd
fi
