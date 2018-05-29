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

# Check for .zen dir in root home
# If not then copy zen.conf from zenadmin to root location
# this will allow root to issue zen-cli commands if installed by zenadmin
if [[ ! -f ~/.zen/zen.conf ]]
then
    mkdir ~/.zen
    cp /home/zenadmin/.zen/zen.conf ~/.zen
fi

# Get date in UTC seconds from epoc for easy math
vpsdate=$(date +%s)
echo "vpsdate:$vpsdate" 

# Get hostname (Row 1)
hostname=$(hostname)
echo "hostname:$hostname"

# Check to see who is running zend and is running (Row 2)
zcuser=$(ps axo user:20,comm | grep zend | awk '{print $1}')
echo "zenduser:$zcuser"

# Check Challenge Balance (Row 3) 
znbalance=$(zen-cli z_gettotalbalance | grep private | awk -F'"' '{print $4}')
echo "znbalance:$znbalance"

# check OS version (Row 4)
osver=$(uname -rv | awk '{print $1 " "$2}')
echo "osversion:$osver"

# Check for OS packages are available for update (Row 5)
npac=$(apt list --upgradable 2>/dev/null | wc -l)
npac=$((npac-1))
echo "ospackagesneedupdate:$npac"

# Check for zend current protocol version running (Row 6)
znpac=$(zen-cli getinfo | grep \"version | awk '{print $2}' | awk -F',' '{print $1}')
echo "zendversion:$znpac"

# Check Disk Space (Row 7)
dskspc=$(df -Th | grep ext4 | awk '{print $6}')
echo "currentdiskspaceused:$dskspc"

# Check that firewall is active (Row 8)
ufwstatus=$(ufw status | grep Status)
echo "ufwstatus:$ufwstatus"
# Check that firewall port 22 is Limited (Row 9)
ufwssh=$(ufw status | grep 22| grep -v v6 | awk '{print $2}')
echo "ufwssh:$ufwssh"
# Check that firewall port 9033 is Allow (Row 10)
ufwscport=$(ufw status | grep 9033| grep -v v6 | awk '{print $2}')
echo "ufwscport:$ufwscport"


# Check that crontab is set for user that installed zend (Row 11)
crona=$(crontab -u $zcuser -l  2>/dev/null | grep acme)
echo "cronacme:$crona"
# Check the agent crontab (Row 12)
cronznm=$(crontab -u root -l 2>/dev/null | grep znmonagent)
echo "cronzmnonagent:$cronznm"

# z_addr shielded address for challenges (Row 12)
zaddr=$(zen-cli z_listaddresses | grep \" | awk -F'"' '{print $2}')
echo "zaddr:$zaddr"

# check the tls cert is verified (Row 13)
cert=$(zen-cli getnetworkinfo | grep tls_cert_verified | awk -F':' '{print $2}' | awk -F',' '{print $1}')
echo "cert:$cert"