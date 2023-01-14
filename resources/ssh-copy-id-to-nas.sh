#!/bin/bash

## Copy ssh public key to NAS. 
## Then create a lock file which can be used by ansible to detect if the public key has already been copied.

SSH_PUBLIC_KEY=/root/.ssh/id_rsa.pub
NAS=patrick@turtle
LOCK_FILE=/home/paperless_user/paperless-ngx/ssh-copy-id-to-nas.lock

ssh-copy-id $SSH_PUBLIC_KEY $NAS && touch $LOCK_FILE
