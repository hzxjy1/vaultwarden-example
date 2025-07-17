#!/bin/bash
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Warning: This script is recommended to run as root"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Check dependencies
command -v openssl >/dev/null 2>&1 || { 
    echo "Error: openssl not found. Please install openssl first."
    exit 1
}

command -v docker >/dev/null 2>&1 || {
    echo "Error: docker not found. Please install docker first."
    exit 1
}

if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    echo "Error: docker-compose not found. Please install docker-compose first."
    exit 1
fi

# Create directories
mkdir -p ssl/private ssl/certs

# Generate SSL cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/private/nginx-selfsigned.key \
    -out ssl/certs/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Company/OU=Department/CN=localhost"

# Start containers
echo "Starting containers..."
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose up -d
else
    docker compose up -d
fi

echo "Setup completed successfully"
