#!/bin/bash
# installznma.sh
# This installs the ZenCash SecureNode Monitor Agent on the VPS server
# Make sure to install this as root only

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as root:"
  exit -1
fi

# Check to see if smartnode directory already exist
if [ -d ~/znmon ]
then
    echo "~/znmon Directory already exist"
    printf "Press Ctrl+C to cancel or Enter to clean up and reinstall:"
    read IGNORE
fi

# Create the directory in root home
cd

rm -r znmon
mkdir znmon

# Check to see that zenadmin home dir exist
if [[ ! -d /home/zenadmin ]]
then
     echo "zenadmin directory does not exist. Exiting"
     exit -1
fi

# Create the directory in smartadmin home
rm -r /home/zenadmin/znmon
mkdir /home/zenadmin/znmon

# Change the directory to ~/snmon/
cd ~/znmon/

# Download the appropriate scripts
wget https://rawgit.com/controllinghand/securenode-monitor/master/znmonagent.sh

# Create a cronjob for monitoring agent to collect data every 10 minutes
# dump the results into the zemadmin znmon directory
# OLD (crontab -l 2>/dev/null | grep -v -F "znmon/zenagent.sh" ; echo "*/10 * * * * ~/znmon/zenagent.sh > /home/zenadmin/znmon/znmon.dat 2>&1" ) | crontab -
(crontab -l 2>/dev/null | grep -v -F "znmon/znmonagent.sh" ; echo "*/10 * * * * ~/znmon/znmonagent.sh" ) | crontab -
chmod 0700 ./znmonagent.sh

# Cleanup old installznma
rm ~/installznma.s*

