#!/bin/bash

# متوقف کردن و غیر فعال کردن سرویس ssh-tunnel.service
sudo systemctl stop ssh-tunnel.service
sudo systemctl disable ssh-tunnel.service

# حذف فایل سرویس
sudo rm /etc/systemd/system/ssh-tunnel.service

# بارگذاری مجدد systemd برای اعمال تغییرات
sudo systemctl daemon-reload

# حذف تنظیمات پروکسی از /etc/environment
sudo sed -i '/http_proxy/d' /etc/environment
sudo sed -i '/https_proxy/d' /etc/environment

# حذف تنظیمات پروکسی از ~/.bashrc و ~/.profile
sed -i '/http_proxy/d' ~/.bashrc
sed -i '/https_proxy/d' ~/.bashrc
sed -i '/http_proxy/d' ~/.profile
sed -i '/https_proxy/d' ~/.profile

# حذف پیکربندی پروکسی برای wget
sed -i '/use_proxy/d' ~/.wgetrc
sed -i '/http_proxy/d' ~/.wgetrc
sed -i '/https_proxy/d' ~/.wgetrc

# حذف پیکربندی پروکسی برای apt
sudo rm /etc/apt/apt.conf.d/proxy.conf

# بارگذاری مجدد تنظیمات محیطی
source /etc/environment

echo "Settings have been reset to default and ssh-tunnel.service has been removed successfully."
