#!/bin/bash
# Learn spam from Spam Maildir folder, ham from INBOX
/usr/bin/sa-learn --spam --no-sync ~/Maildir/.Spam/cur
/usr/bin/sa-learn --ham --no-sync ~/Maildir/cur
/usr/bin/sa-learn --sync

# Removes all files from ~/Maildir/.Spam/cur that are older than
# 31 days ago

find ~/Maildir/.Spam/cur -mtime +30 -exec rm -f {} \;
