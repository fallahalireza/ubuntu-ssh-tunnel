#!/bin/bash

# دریافت مشخصات سرور از کاربر
read -p "لطفاً IP سروری که دسترسی به پکیج‌ها ندارد را وارد کنید: " LOCAL_HOST
read -p "لطفاً نام کاربری سرور محدود شده را وارد کنید: " LOCAL_USER
read -s -p "لطفاً کلمه عبور سرور محدود شده را وارد کنید: " LOCAL_PASS
echo
read -p "لطفاً IP سروری که به اینترنت دسترسی دارد را وارد کنید: " REMOTE_HOST
read -p "لطفاً نام کاربری سرور اینترنت‌دار را وارد کنید: " REMOTE_USER
read -s -p "لطفاً کلمه عبور سرور اینترنت‌دار را وارد کنید: " REMOTE_PASS
echo
read -p "لطفاً پورتی که می‌خواهید برای تونل محلی استفاده کنید (پیش‌فرض 1080): " LOCAL_SOCKS_PORT

# تنظیم پیش‌فرض پورت محلی در صورت عدم وارد کردن توسط کاربر
LOCAL_SOCKS_PORT=${LOCAL_SOCKS_PORT:-1080}

# ایجاد فایل سرویس systemd
cat <<EOF | sudo tee /etc/systemd/system/ssh-tunnel.service
[Unit]
Description=SSH Tunnel Service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/ssh -D ${LOCAL_SOCKS_PORT} -N ${REMOTE_USER}@${REMOTE_HOST}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# فعال سازی و راه اندازی سرویس
sudo systemctl enable ssh-tunnel.service
sudo systemctl start ssh-tunnel.service

# بررسی وضعیت سرویس
sudo systemctl status ssh-tunnel.service

# تنظیم پروکسی در فایل /etc/environment
cat <<EOF | sudo tee -a /etc/environment
export http_proxy="socks5://localhost:${LOCAL_SOCKS_PORT}"
export https_proxy="socks5://localhost:${LOCAL_SOCKS_PORT}"
EOF

# اعمال تنظیمات محیطی
source /etc/environment

# تنظیم پروکسی برای apt
cat <<EOF | sudo tee /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "socks5h://localhost:${LOCAL_SOCKS_PORT}";
Acquire::https::Proxy "socks5h://localhost:${LOCAL_SOCKS_PORT}";
EOF

echo "تنظیمات با موفقیت انجام شد."
