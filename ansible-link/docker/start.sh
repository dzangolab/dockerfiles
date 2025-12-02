#!/bin/bash

set -e

# Copy configuration files if they exist
if [ -f "/config/config.yml" ]; then
    cp /config/config.yml /etc/ansible-link/config.yml
fi

if [ -f "/config/hosts" ]; then
    cp /config/hosts /etc/ansible-link/hosts
fi

if [ -f "/config/ssh_key" ]; then
    mkdir -p /root/.ssh
    cp /config/ssh_key /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
fi

if [ -f "/config/ssh_config" ]; then
    mkdir -p /root/.ssh
    cp /config/ssh_config /root/.ssh/config
fi

# Execute the command
exec "$@"