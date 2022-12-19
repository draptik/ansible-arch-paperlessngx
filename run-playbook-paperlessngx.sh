#!/bin/sh

ansible-playbook \
    --inventory ansible-inventory.cfg \
    playbook-arch-paperlessngx.yml
