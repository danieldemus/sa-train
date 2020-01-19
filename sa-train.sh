#!/bin/bash
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

if [ -r /etc/sa-train.conf ]; then
    while read -r name value; do
        if [[ ! "$name" =~ "$\w*#" ]]; then
            typeset "$name=$value"
        fi
    done < /etc/sa-train.conf
fi

spammed_group=${spammed_group:-sa-train}

SPAMMED_USERS=$(groupmems -l -g "$spammed_group" 2> /dev/null)

if [ -z "$SPAMMED_USERS" ]; then
    echo "No users have been added to the \"$spammed_group\" group. Canceling execution."
    exit 2
fi

for USERNAME in "$SPAMMED_USERS"; do
    sudo -U $USERNAME -H /usr/bin/sa-train-user.sh
done
