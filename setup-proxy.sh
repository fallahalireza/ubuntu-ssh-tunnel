#!/bin/bash

# Get server details from user
echo "server not access"

read -p "IP Address (server not access): " LOCAL_HOST
read -p "Port (server not access): " LOCAL_PORT
read -p "Username (server not access): " LOCAL_USER
read -p "Password (server not access): " LOCAL_PASS
echo
echo "server access"
read -p "IP Address (server access): " REMOTE_HOST
read -p "Port (server access): " REMOTE_PORT
read -p "Username (server access): " REMOTE_USER
read -p "Password (server access): " REMOTE_PASS
echo
read -p "Please enter the local port you want to use for the SOCKS proxy (default is 1080): " LOCAL_SOCKS_PORT

# Set default local port if not provided by user
LOCAL_SOCKS_PORT=${LOCAL_SOCKS_PORT:-1080}

# فایل سرویس systemd را ایجاد می‌کنیم
sudo tee /etc/systemd/system/ssh-tunnel.service << EOF
[Unit]
Description=SSH Tunnel Service
After=network.target

[Service]
User=${LOCAL_USER}
ExecStart=/usr/bin/expect -c "spawn ssh -o StrictHostKeyChecking=no -D ${LOCAL_SOCKS_PORT} -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}; expect \"password:\"; send \"${REMOTE_PASS}\\r\"; interact; sleep 7200"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# سطح دسترسی مناسب برای فایل سرویس را تنظیم می‌کنیم
sudo chmod 644 /etc/systemd/system/ssh-tunnel.service

# فعال‌سازی و راه‌اندازی سرویس
sudo systemctl daemon-reload
sudo systemctl enable ssh-tunnel.service
sudo systemctl restart ssh-tunnel.service

# بررسی وضعیت سرویس
sudo systemctl status ssh-tunnel.service

# تنظیمات پروکسی را در /etc/environment اعمال می‌کنیم
sudo tee -a /etc/environment << EOF
export http_proxy="socks5://localhost:${LOCAL_SOCKS_PORT}"
export https_proxy="socks5://localhost:${LOCAL_SOCKS_PORT}"
EOF

# تنظیمات محیطی را اعمال می‌کنیم
source /etc/environment

# پیکربندی پروکسی برای apt
sudo tee /etc/apt/apt.conf.d/proxy.conf << EOF
Acquire::http::Proxy "socks5h://localhost:${LOCAL_SOCKS_PORT}";
Acquire::https::Proxy "socks5h://localhost:${LOCAL_SOCKS_PORT}";
EOF

echo "Settings applied successfully."
