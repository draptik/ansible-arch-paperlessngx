#!/bin/bash

## Copy ssh public key to NAS. 
## Then create a lock file which can be used by ansible to detect if the public key has already been copied.

set -o nounset
set -o errexit

readonly SSH_PUBLIC_KEY=/root/.ssh/id_rsa.pub
readonly NAS=patrick@turtle
readonly LOCK_FILE=/home/paperless_user/paperless-ngx/ssh-copy-id-to-nas.lock

ssh-copy-id $SSH_PUBLIC_KEY $NAS && touch $LOCK_FILE
