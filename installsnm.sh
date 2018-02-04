#!/bin/bash
# installsnm.sh
# This installs the SmartNode Monitor 
# This script runs on your MAC terminal

# Check to see if smartnode monitor directory already exist
if [ -d ~/snmon ]
then
    echo "~/snmon Directory already exist"
    printf "Press Ctrl+C to cancel or Enter to clean up and reinstall:"
    read IGNORE
fi

# Create the directory in home dir location
cd

rm -r snmon
mkdir snmon

# Change the directory to ~/snmon/
cd ~/snmon/

# Download the snmon.sh main script
# make sure to issue a ssh-add before you run this script
# This will let you bypass having to enter a password every time
curl -O https://raw.githubusercontent.com/controllinghand/smartnode-monitor/master/snmon.sh

# Download the iplist file with example
# Please edit this file with the IP addresses of all your smartnodes
curl -O https://raw.githubusercontent.com/controllinghand/smartnode-monitor/master/iplist

# Cleanup old installsnm
rm ~/installsnm.s*
