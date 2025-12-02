FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ssh-client \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible and dependencies
RUN pip3 install ansible ansible-runner

# Download and install ansible-link
RUN wget https://github.com/lfkdev/ansible-link/releases/download/v2.1.1/ansible-link-2.1.1.zip \
    && unzip ansible-link-2.1.1.zip \
    && rm ansible-link-2.1.1.zip \
    && cd ansible-link-2.1.1 \
    && pip3 install -r requirements.txt \
    && pip3 install gunicorn

# Copy application
RUN mkdir -p /app && cp -r ansible-link-2.1.1/* /app/ \
    && rm -rf ansible-link-2.1.1

# Create directories
RUN mkdir -p /etc/ansible-link /data /config

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash ansible \
    && chown -R ansible:ansible /app /etc/ansible-link /data /config

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app
USER ansible

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5001/health || exit 1

EXPOSE 5001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3", "-m", "gunicorn", "--workers", "1", "--bind", "0.0.0.0:5001", "wsgi:application"]