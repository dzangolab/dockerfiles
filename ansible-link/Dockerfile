FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y wget unzip ssh-client && \
    rm -rf /var/lib/apt/lists/*

# Download ansible-link
RUN wget https://github.com/lfkdev/ansible-link/releases/download/v2.1.1/ansible-link-2.1.1.zip && \
    unzip ansible-link-2.1.1.zip && \
    rm ansible-link-2.1.1.zip

# WORKDIR /ansible-link-2.1.1

# Install Python dependencies globally
RUN pip3 install -r requirements.txt && \
    pip3 install gunicorn && \
    pip3 install ansible

# Create non-root user AFTER installing dependencies
RUN useradd -m -u 1000 -s /bin/bash ansible

# Create directories with correct permissions
RUN mkdir -p /etc/ansible-link /root/.ssh /etc/ansible-link/jobs && \
    chown -R ansible:ansible /etc/ansible-link /root/.ssh /etc/ansible-link/jobs

USER ansible

EXPOSE 5001

CMD ["gunicorn", "--workers", "1", "--bind", "0.0.0.0:5001", "wsgi:application"]