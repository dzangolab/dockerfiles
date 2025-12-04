FROM python:3.9-slim

ENV ANSIBLE_CONFIG=/etc/ansible-link/ansible.cfg \
    ANSIBLE_PRIVATE_KEY_FILE=/etc/ansible-link/ssh_key \
    ANSIBLE_HOST_KEY_CHECKING=False

# Install Linux deps
RUN apt-get update && \
    apt-get install -y wget unzip ssh-client python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install Python deps
RUN pip3 install --no-cache-dir ansible gunicorn

# Download ansible-link release
RUN wget https://github.com/lfkdev/ansible-link/releases/download/v2.1.1/ansible-link-2.1.1.zip && \
    unzip ansible-link-2.1.1.zip && \
    pip3 install -r requirements.txt && \
    rm ansible-link-2.1.1.zip

# Create config dirs
RUN mkdir -p /etc/ansible-link /root/.ssh

# Preload default SSH config (Ansible role may overwrite)
COPY templates/ssh-config.yml.j2 /root/.ssh/config

# Entrypoint will only run gunicorn
CMD ["gunicorn", "--workers", "1", "--bind", "0.0.0.0:5001", "wsgi:application"]
