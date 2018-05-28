# ZenCash securenode-monitor
### Bash Monitor for securenode on Ubuntu 16.04 LTS x64 agent
### Bash Monitor for MAC OS 10.13.2 server
### ATTENTION: This installer is only suitable for a dedicated vps for the agent and MAC OS for the server. 
### This Repository will Monitor a zencash securenode and is designed to run from your MAC if you have MULTIPLE securenodes
### This script assumes you already have a ZenCash securenode installed. And you followed the guide from https://steemit.com/zencash/@controllinghand/zencash-securenode-setup-guide-v1-0-vps-on-digital-ocean-mac-local-wallet

### You must run this script as root on your VPS even if you installed zend as another user like zenadmin
### You will run this script as your normal Mac user from a terminal to view all of your securenodes

#### First Step
#### This shell script accomplishes the following on your VPS (Installs Zencash Secure Node Monitor Agent)
#### Please install this on all of your ZenCash Secure Nodes VPS
1. Creates a znmon directory in the root home directory ~/znmon
2. Creates a znmon directory in the zenadmin home directory so that ssh can grab data 
2. Installs the znmonagent.sh in the ~/znmon directory for the root user
3. Creates a crontab job that runs every 10 mins znmonagent.sh
4. znmonagent.sh collects the following information in this order
  - date script collected data
  - hostname
  - checks to see if the securenode is up and running
  - check the OS the securenode is running
  - check to see if there are any OS packages that need to be updated
  - check the protocol version of securenode currently running
  - check % of disk space used
  - checks to see if the firewall is active
  - checks to see that port 22 ssh is limit
  - checks to see that port 9678 for smartnode is allow
  - checks to see if all the recommended cronjob are installed
5. All of this data is stored in the zenadmin home directory in a file /home/zenadmin/znmon/znmon.dat

#### Second Step
#### This shell script also accomplishes the following on your Mac OS (Installs ZenCash Securenode Monitor Server)
1. To avoid having to enter in the ssh password evertime please do a `ssh-add` before running the script
2. Creates a znmon directory in the Mac user home dir ~/znmon
3. Installs a znmon.sh script in the ~/znmon directory for the Mac user
4. Creates a iplist of all your SecureNodes (You will have to input manually)
5. When you run znmon.sh it collects all of the znmon.dat files from each SecureNodes and reports on status
6. There are three status [OK] [Warning] [Failed]


#### Login to your vps as zenadmin and su - (switch to the root user to install):
```
wget -N https://rawgit.com/controllinghand/securenode-monitor/master/installznma.sh
bash ./installznma.sh
```

#### Login to your Mac and bring up a terminal:
```
curl -O https://raw.githubusercontent.com/controllinghand/securenode-monitor/master/installznm.sh
bash ./installznm.sh
```
### Donation to my ZenCash please: zniXufq48dRNYdHQhY5xDeSQzQ3ktGeRcCU
