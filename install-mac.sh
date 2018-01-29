#!/bin/bash
# install-mac.sh
# Installs smartnode on Ubuntu 16.04 LTS x64
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

# Secure copy sshd_config to VPS
scp sshd_config-copy /etc/ssh/sshd_config
rcp systemctl reload sshd

ssh-keygen -t rsa -b 2048
scp id_rsa.pub smartadmin@192.241.211.14:.ssh/authorized_keys
