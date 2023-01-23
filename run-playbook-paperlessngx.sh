#!/bin/sh

set -o nounset
set -o errexit

ansible-playbook \
    --inventory ansible-inventory.cfg \
    playbook-arch-paperlessngx.yml
