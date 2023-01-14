#!/bin/sh

ansible-playbook \
    --vault-password-file=.vault_pass \
    --inventory ansible-inventory.cfg \
    playbook-arch-backup-paperlessngx.yml
