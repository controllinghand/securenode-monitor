#!/bin/bash
# installsnma.sh
# This installs the SmartNode Monitor Agent on the VPS server
# Make sure to install this as root only

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as root:"
  exit -1
fi

# Check to see if smartnode directory already exist
if [ -d ~/snmon ]
then
    echo "~/snmon Directory already exist"
    printf "Press Ctrl+C to cancel or Enter to clean up and reinstall:"
    read IGNORE
fi

# Create the directory in root home
cd

rm -r snmon
mkdir snmon

# Change the directory to ~/snmon/
cd ~/snmon/

# Download the appropriate scripts
wget https://rawgit.com/controllinghand/smartnode-monitor/master/snmonagent.sh

# Create a cronjob for monitoring agent to collect data every 10 minutes
(crontab -l 2>/dev/null | grep -v -F "snmon/snmonagent.sh" ; echo "*/10 * * * * ~/snmon/snmonagent.sh" ) | crontab -
chmod 0700 ./snmonagent.sh
