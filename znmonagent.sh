#!/bin/bash
SHELL=/bin/bash
PATH=$PATH:/usr/sbin
# This is znmonagent script that will collect data every 10 mins
# It will save the info in a data file call znmon.dat
# This file can be view from your local wallet machine via ssh
# This script should be run by root

#Redirect stdout (>) into a named pipe ( <() ) running "tee"
exec > >(tee -i /home/zenadmin/znmon/znmon.dat)
#exec 2>&1

# Go to root home dir
cd

# Check for .smartcash dir in root home
# If not then copy smartcash.conf from smartadmin to root location
# this will allow root to issue smartcash-cli commands if installed by smartadmin
# Keep just in case?
#if [[ ! -f ~/.smartcash/smartcash.conf ]]
#then
#    mkdir ~/.smartcash
#    cp /home/smartadmin/.smartcash/smartcash.conf ~/.smartcash
#fi

# Get date in UTC seconds from epoc for easy math
vpsdate=$(date +%s)
echo "vpsdate:$vpsdate" 

# Get hostname
hostname=$(hostname)
echo "hostname:$hostname"

# Check to see if zend is running
zcuser=$(ps axo user:20,comm | grep zend | awk '{print $1}')
echo "zenduser:$zcuser"

# Check securenode status
# Keep just in case?
#snstatus=$(smartcash-cli smartnode status | grep status | awk '{print $2" "$3" "$4}' )
#echo "smartnodestatus:$snstatus"

# check OS version
osver=$(uname -rv | awk '{print $1 " "$2}')
echo "osversion:$osver"

# Check for OS packages are available for update
npac=$(apt list --upgradable 2>/dev/null | wc -l)
npac=$((npac-1))
echo "ospackagesneedupdate:$npac"

# Check for zend current protocol version running
# Keep just in case
#snpac=$(smartcash-cli getinfo | grep protocolversion | awk '{print $2}' | awk -F',' '{print $1}')
#echo "smartcashdversion:$snpac"

# Check Disk Space
dskspc=$(df -Th | grep ext4 | awk '{print $6}')
echo "currentdiskspaceused:$dskspc"

# Check that firewall is active
ufwstatus=$(ufw status | grep Status)
echo "ufwstatus:$ufwstatus"
# Check that firewall port 22 is Limited
ufwssh=$(ufw status | grep 22| grep -v v6 | awk '{print $2}')
echo "ufwssh:$ufwssh"
# Check that firewall port 9678 is Allow
ufwscport=$(ufw status | grep 9678| grep -v v6 | awk '{print $2}')
echo "ufwscport:$ufwscport"
# Check that no other ports are open
snufwother=$(ufw status | grep -v -e "Status" -e "22" -e "To" -e "--" -e "9678" |wc -l)
if [[ $snufwother -gt 2 ]]
then
    echo "ufwother:Check Firewall ports only 22 and 9678 should be open"
else
    echo "ufwother:none"
fi

# Check that crontab is set for user that installed smartcashd
crona=$(crontab -u $zcuser -l  2>/dev/null | grep acme)
echo "cronacme:$crona"
cronznm=$(crontab -u root -l 2>/dev/null | grep znmonagent)
echo "cronzmnonagent:$cronznm"
