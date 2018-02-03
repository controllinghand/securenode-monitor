#!/bin/bash
# This is snmonagent script that will collect data every 10 mins
# It will save the info in a data file call snmon.dat
# This file can be view from your local wallet machine via ssh
# This script should be run by root
# root requires the smartcash.conf file for rpcuser and rpcpassword 
# so that it can issue smartcash-cli
# this script will check for that

# Go to root home dir
cd

# Check for .smartcash dir in root home
# If not then copy smartcash.conf from smartadmin to root location
# this will allow root to issue smartcash-cli commands if installed by smartadmin
if [[ ! -d ~/.smartcash ]]
then
    mkdir ~/.smartcash
    cp /home/smartadmin/.smartcash/smartcash.conf ~/.smartcash
fi

# Get date in UTC seconds from epoc for easy math
date=$(date +%s)
echo "date:$date"

# Get hostname
hostname=$(hostname)
echo "hostname:$hostname"

# Check to see if smartcashd is running
scuser=$(ps axo user:20,comm | grep smartcashd | awk '{print $1}')
echo "smartcashduser:$scuser"

# Check smartnode status
snstatus=$(smartcash-cli smartnode status | grep status | awk '{print $2" "$3" "$4}' )
echo "smartnodestatus:$snstatus"

# check OS version
osver=$(uname -rv | awk '{print $1 " "$2}')
echo "osversion:$osver"

# Check for OS packages are available for update
npac=$(apt list --upgradable 2>/dev/null | wc -l)
npac=$((npac-1))
echo "ospackagesneedupdate:$npac"

# Check for smartcashd current version
snpac=$(apt list --installed 2> /dev/nul | grep smartcashd | awk '{print $2}')
echo "smartcashdversion:$snpac"

# Check Disk Space
dskspc=$(df -Th | grep ext4 | awk '{print $6}')
echo "currentdiskspaceused:$dskspc"

# Check that firewall is active
ufwstatus=$(ufw status  2>/dev/null| grep Status)
echo "ufwstatus:$ufwstatus"
# Check that firewall port 22 is Limited
ufwssh=$(ufw status  2>/dev/null| grep 22| grep -v v6)
echo "ufwssh:$ufwssh"
# Check that firewall port 9678 is Allow
ufwscport=$(ufw status  2>/dev/null| grep 9678| grep -v v6)
echo "ufwscport:$ufwscport"
# Check that no other ports are open
snufwother=$(ufw status 2>/dev/null| grep -v -e "Status" -e "22" -e "To" -e "--" -e "9678" |wc -l)
if [[ $snufwother -gt 2 ]]
then
    echo "ufwother:Check Firewall ports only 22 and 9678 should be open"
else
    echo "ufwother:none"
fi

# Check that crontab is set for user that installed smartcashd
cronmk=$(crontab -u $scuser -l  2>/dev/null| grep makerun)
echo "cronmakerun:$cronmk"
cronck=$(crontab -u $scuser -l  2>/dev/null| grep checkdaemon)
echo "croncheckdaemon:$cronck"
cronup=$(crontab -u $scuser -l  2>/dev/null| grep upgrade)
echo "cronupgrade:$cronup"
croncl=$(crontab -u $scuser -l  2>/dev/null| grep clearlog)
echo "cronmakerun:$croncl"
cronsnm=$(crontab -l 2>/dev/null | grep snmonagent)
echo "cronsmnonagent:$cronsnm"
