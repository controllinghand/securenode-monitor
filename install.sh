#!/bin/bash
# install.sh
# Secures smartnode on Ubuntu 17.10 x64
# 

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as root:"
  exit -1
fi

# Warning that the script will reboot the server
echo "WARNING: This script will reboot the server when it's finished."
printf "Press Ctrl+C to cancel or Enter to continue: "
read IGNORE


# adduser smartadmin
adduser smartadmin
gpasswd -a smartadmin sudo

# Setup Firewall
apt-get install ufw
ufw allow ssh/tcp
ufw limit ssh/tcp
ufw allow 9678/tcp
ufw logging on
ufw enable
ufw status

# Reboot the server
echo "Rebooting the server so that changes will take effect."
printf "Enter to continue: "
read IGNORE
sudo reboot
