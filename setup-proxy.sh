#!/bin/bash

# Get server details from user
read -p "IP Address (server not access): " LOCAL_HOST
read -p "Port (server not access): " LOCAL_PORT
read -p "Username (server not access): " LOCAL_USER
read -p "Password (server not access): " LOCAL_PASS
echo
read -p "IP Address (server access): " REMOTE_HOST
read -p "Port (server access): " REMOTE_PORT
read -p "Username (server access): " REMOTE_USER
read -p "Password (server access): " REMOTE_PASS
echo
read -p "Please enter the local port you want to use for the SOCKS proxy (default is 1080): " LOCAL_SOCKS_PORT

# Set default local port if not provided by user
LOCAL_SOCKS_PORT=${LOCAL_SOCKS_PORT:-1080}

# Create systemd service file
cat <<EOF | sudo tee /etc/systemd/system/ssh-tunnel.service
[Unit]
Description=SSH Tunnel Service
After=network.target

[Service]
User=${LOCAL_USER}
ExecStart=/usr/bin/expect -c '
spawn ssh -D ${LOCAL_SOCKS_PORT} -p ${REMOTE_PORT} -N ${REMOTE_USER}@${REMOTE_HOST}
expect "password:"
send "${REMOTE_PASS}\r"
interact'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl enable ssh-tunnel.service
sudo systemctl start ssh-tunnel.service

# Check the service status
sudo systemctl status ssh-tunnel.service

# Configure proxy settings in /etc/environment
cat <<EOF | sudo tee -a /etc/environment
export http_proxy="socks5://localhost:${LOCAL_SOCKS_PORT}"
export https_proxy="socks5://localhost:${LOCAL_SOCKS_PORT}"
EOF

# Apply environment settings
source /etc/environment

# Configure proxy for apt
cat <<EOF | sudo tee /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "socks5h://localhost:${LOCAL_SOCKS_PORT}";
Acquire::https::Proxy "socks5h://localhost:${LOCAL_SOCKS_PORT}";
EOF

echo "Settings applied successfully."
