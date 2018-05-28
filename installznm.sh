#!/bin/bash
# installznm.sh
# This installs the ZenCash SecureNode Monitor 
# This script runs on your MAC terminal

# Check to see if ZenCash securenode monitor directory already exist
if [ -d ~/znmon ]
then
    echo "~/znmon Directory already exist"
    printf "Press Ctrl+C to cancel or Enter to clean up and reinstall:"
    read IGNORE
fi

# Create the directory in home dir location
cd

rm -r znmon
mkdir znmon

# Change the directory to ~/snmon/
cd ~/znmon/

# Download the znmon.sh main script
# make sure to issue a ssh-add before you run this script
# This will let you bypass having to enter a password every time
curl -O https://raw.githubusercontent.com/controllinghand/securenode-monitor/master/znmon.sh
chmod 700 ~/znmon/znmon.sh

# Download the iplist file with example
# Please edit this file with the IP addresses of all your securenodes
curl -O https://raw.githubusercontent.com/controllinghand/securenode-monitor/master/iplist

# Cleanup old installsnm
rm ~/installznm.s*
