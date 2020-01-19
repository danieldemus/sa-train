# sa-train
A bash script and systemd setup that run sa-learn on all mailbox folders for users that
are members of the satrain group.

It is assumed that read mails in a Spam folder in the root of a user's maildir has spam,
while everthing else is ham. A directory called SpamSuspect is assumed to contain mail
that needs to be manually categorised by being moved into Spam or another folder. 

All the specific names can be configured in either */etc/sa-train.conf* or
*~/.sa-train/config* where the user configuration overrides the system configuration.

**SETTINGS:**

Possible configuration values are (with the default value if not otherwise specified
in config):

**spam_folder .Spam**
    The subfolder in the user's mailbox folder that contains mail to train as spam.
    Only read mails are used, so if the MTA delivers mail marked as spam by spamassassin
    to this folder as unread, the user can verify them by marking them as read, after
    which sa-train will add them to the bayesian filter.

**max_age 90**
    The maximum age in days of mails to train spamassassin with. This is probably only
    relevant the first time training is performed. Normally sa-train only examines mails
    that have a modified date more recent than the newest mail in the last training
    session. To re-train spamassassin remove the ~/.sa-train/last* files, delete the
    bayesian database and run sa-train.sh as root.

**spammed_group sa-train**
    The name of the unix group, the members of which will have their mailboxes used to
    train the spamassassin bayesian filter. Each users filter is trained using their
    specific mailboxes, so the filtering conform to their patterns of spam.
    *This setting is only relevant in the global config file and is ignored in the user configs.*
