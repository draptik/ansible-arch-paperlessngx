#!/bin/bash

## Assumptions:
##
##  - Restic is installed
##  - Restic repo exists on NAS
##  - SFTP works without credentials
##
## This script must be executed as root on the target system.
## Why? Only root has access to the docker volumes.
##
## NOTE: This is "as documented". See https://docs.paperless-ngx.com/administration/#backup for details:
##  "
##   Options available to docker installations:
##   Backup the docker volumes. These usually reside within /var/lib/docker/volumes on the host and you need to be root in order to access them.
##  " 

## NAS Settings ----------------------------------
NAS_USER="patrick"
NAS_NAME="turtle"
REPO_NAME="restic-paperless"
REPO=$NAS_USER@$NAS_NAME:$REPO_NAME

## Paperless docker volume paths -----------------
PAPERLESS_DOCKER_VOLUME_DATA=/var/lib/docker/volumes/paperless-ngx_data
PAPERLESS_DOCKER_VOLUME_MEDIA=/var/lib/docker/volumes/paperless-ngx_media
PAPERLESS_DOCKER_VOLUME_PGDATA=/var/lib/docker/volumes/paperless-ngx_pgdata

## The actual backups... -------------------------
## Assumption: Restic credentials are configured
restic \
    --repo sftp:$REPO \
    backup \
        $PAPERLESS_DOCKER_VOLUME_DATA \
        $PAPERLESS_DOCKER_VOLUME_MEDIA \
        $PAPERLESS_DOCKER_VOLUME_PGDATA
