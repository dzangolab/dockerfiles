#!/bin/bash
set -e

# Copy default configs if /config is empty
if [ -z "$(ls -A /config 2>/dev/null)" ]; then
    echo "Config directory is empty, copying defaults..."
    cp -r /default-configs/* /config/
fi

# Always copy from /config to app locations
cp -f /config/config.yml /app/config.yml 2>/dev/null || true
cp -f /config/hosts /etc/ansible-link/hosts 2>/dev/null || true

# Copy SSH files if they exist
if [ -f "/config/ssh_key" ]; then
    mkdir -p /home/ansible/.ssh
    cp /config/ssh_key /home/ansible/.ssh/id_rsa
    chmod 600 /home/ansible/.ssh/id_rsa
    chown ansible:ansible /home/ansible/.ssh/id_rsa
fi

if [ -f "/config/ssh_config" ]; then
    mkdir -p /home/ansible/.ssh
    cp /config/ssh_config /home/ansible/.ssh/config
    chown ansible:ansible /home/ansible/.ssh/config
fi

# Create ansible.cfg
cat > /etc/ansible-link/ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = /etc/ansible-link/hosts
EOF

[ -f "/home/ansible/.ssh/id_rsa" ] && \
    echo "private_key_file = /home/ansible/.ssh/id_rsa" >> /etc/ansible-link/ansible.cfg

# Ensure directories
mkdir -p /data/jobs /etc/ansible-link/playbooks
chown -R ansible:ansible /data /etc/ansible-link

# Start application
exec python3 -m gunicorn --workers 1 --bind 0.0.0.0:5001 wsgi:application