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

set -o nounset
set -o errexit

DEBUG_FILE="/home/paperless_user/paperless-ngx/log.txt"

## NAS Settings ----------------------------------
readonly NAS_USER="patrick"
readonly NAS_NAME="turtle"
readonly REPO_NAME="restic-paperless"
readonly REPO=$NAS_USER@$NAS_NAME:$REPO_NAME

## Paperless docker volume paths -----------------
readonly PAPERLESS_DOCKER_VOLUME_DATA=/var/lib/docker/volumes/paperless-ngx_data
readonly PAPERLESS_DOCKER_VOLUME_MEDIA=/var/lib/docker/volumes/paperless-ngx_media
readonly PAPERLESS_DOCKER_VOLUME_PGDATA=/var/lib/docker/volumes/paperless-ngx_pgdata

## Docker compose script location ----------------
readonly DOCKER_COMPOSE_DIRECTORY="/home/paperless_user/paperless-ngx"

## Shut down docker-compose ----------------------
echo "Shutting down docker..." >> "${DEBUG_FILE}"
docker-compose --project-directory="${DOCKER_COMPOSE_DIRECTORY}" down >> "${DEBUG_FILE}"

## The actual backups... -------------------------
readonly RESTIC_PASSWORD_FILE="/root/restic-pw"

echo "Trying to backup ${PAPERLESS_DOCKER_VOLUME_DATA}, ${PAPERLESS_DOCKER_VOLUME_MEDIA} and ${PAPERLESS_DOCKER_VOLUME_PGDATA}..." >> "${DEBUG_FILE}"

restic \
    --repo sftp:$REPO \
    --password-file "${RESTIC_PASSWORD_FILE}" \
    backup \
        "${PAPERLESS_DOCKER_VOLUME_DATA}" \
        "${PAPERLESS_DOCKER_VOLUME_MEDIA}" \
        "${PAPERLESS_DOCKER_VOLUME_PGDATA}" \
    >> "${DEBUG_FILE}"

echo "Finished with restic."

## Restart docker-compose ------------------------
echo "Restarting docker..." >> "${DEBUG_FILE}"
docker-compose --project-directory="${DOCKER_COMPOSE_DIRECTORY}" up >> "${DEBUG_FILE}"

echo "DONE." >> "${DEBUG_FILE}"
