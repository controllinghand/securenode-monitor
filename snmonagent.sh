#!/bin/bash
# This is snmon script that will collect data every 10 mins
# It will save the info in a data file call snmon.dat
# This file can be view from your local wallet machine via ssh

# Get date
date

# Get hostname
hostname

# Check to see if smartcashd is running
scuser=$(ps axo user:20,comm | grep smartcashd | awk '{print $1}')
echo $scuser

# Check smartnode status
smartcash-cli smartnode status | grep status | awk '{print $2" "$3" "$4}'

# check OS version
uname -rv | awk '{print $1 " "$2}'

# Check for OS packages are available for update
npac=$(apt list --upgradable 2>/dev/null | wc -l)
npac=$((npac-1))
echo $npac

# Check Disk Space
df -Th | grep ext4 | awk '{print $6}'

# Check that firewall is active
ufw status | grep Status
# Check that firewall port 22 is Limited
ufw status | grep 22
# Check that firewall port 9678 is Allow
ufw status | grep 9678

# Check that crontab is set for user that installed smartcashd
crontab -u $scuser -l
