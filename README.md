# smartnode-securenode
### Bash securenode for smartnode on Ubuntu 16.04 LTS x64
### ATTENTION: This installer is only suitable for a dedicated vps. 
### This Repository will secure a smartnode that was setup with root and no other user
### This script Assumes you already have a Smartnode installed. And you followed the guide from https://steemit.com/smartcash/@controllinghand/smartcash-smartnode-setup-guide-v1-4-mac-version-with-smartnode-checks-and-anti-ddos-optional-bootstrap or https://forum.smartcash.cc/t/smartcash-smartnode-setup-guide-v2-1-mac-version-quick-setup/3022

### You must run this script as root 

#### This shell script accomplishes the following 
1. Creates a smartadmin user
2. Sets up a firewall and Opens up the correct ports for the SmartNode to function later
3. Give the smartadmin the ability to elevate the user privileges when needed by adding the user to the sudo group with the command
4. Disables roots ability to ssh

#### Login to your vps as smartadmin or ID you used to run smartcashd, donwload the install.sh file and then run it:
```
wget https://rawgit.com/controllinghand/smartnode-securenode/master/install.sh
bash ./install.sh
```
#### At the end of the install your server will reboot so that the changes will take effect

### Donation to my Smartcash please: SebFkuHrqDnj3obXvMtfxtQKRgFeVpXF5x
