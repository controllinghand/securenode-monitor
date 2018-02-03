# smartnode-monitor
### Bash Monitor for smartnode on Ubuntu 16.04 LTS x64 agent
### Bash Monitor for MAC OS 10.13.2 server
### ATTENTION: This installer is only suitable for a dedicated vps for the agent and MAC OS for the server. 
### This Repository will Monitor a smartnode and is designed to run from your MAC if you have MULTIPLE smartnodes
### This script assumes you already have a Smartnode installed. And you followed the guide from https://steemit.com/smartcash/@controllinghand/smartcash-smartnode-setup-guide-v1-4-mac-version-with-smartnode-checks-and-anti-ddos-optional-bootstrap or https://forum.smartcash.cc/t/smartcash-smartnode-setup-guide-v2-1-mac-version-quick-setup/3022
### This also assumes that you have secured you node and have followed these guides https://steemit.com/smartcash/@controllinghand/secure-your-smartcash-smartnode-vps-on-ubuntu-16-04-with-a-mac-wallet-v1-0 or https://forum.smartcash.cc/t/secure-your-smartcash-smartnode-vps-on-ubuntu-16-04-with-a-mac-wallet-v1-0/3025

### You must run this script as root on your VPS even if you installed smartcashd as another user like smartadmin
### You will run this script as your normal Mac user from a terminal to view all of your smartnodes

#### First Step
#### This shell script accomplishes the following on your VPS (Installs SmartNode Monitor Agent)
#### Please install this on all of your SmartNode VPS
1. Creates a snmon directory in the root home directory ~/snmon
2. Creates a snmon directory in the smartadmin home directory so that ssh can grab data 
2. Installs the snmonagent.sh in the ~/snmon directory for the root user
3. Creates a crontab job that runs every 30 mins snmonagent.sh
4. snmonagent.sh collects the following information in this order
  - date script collected data
  - hostname
  - the user that is running smartcashd process 
  - checks to see if the smartnode is up and running
  - check the OS the smartnode is running
  - check to see if there are any OS packages that need to be updated
  - check the version of smartcashd
  - check % of disk space used
  - checks to see if the firewall is active
  - checks to see that port 22 ssh is limit
  - checks to see that port 9678 for smartnode is allow
  - checks to see if all the recommended cronjob are installed
5. All of this data is stored in the smartadmin home directory in a file /home/smartadmin/snmon/snmon.dat

#### Second Step
#### This shell script also accomplishes the following on your Mac OS (Installs SmartNode Monitor Server)
1. Creates a snmon directory in the Mac user home dir ~/snmon
2. Installs a snmon.sh script in the ~/snmon directory for the Mac user
3. Creates a iplist of all your SmartNodes (You will have to input manually)
4. When you run snmon.sh it collects all of the snmon.dat files from each SmartNode and reports on status
5. There are three status [OK] [Warning] [Failed]


#### Login to your vps as smartadmin and su - (switch to the root user to install):
```
wget -N https://rawgit.com/controllinghand/smartnode-securenode/master/installsnma.sh
bash ./installsnma.sh
```

#### Login to your Mac and bring up a terminal:
```
curl -s https://rawgit.com/controllinghand/smartnode-monitor/master/installsnm.sh
bash ./installsnm.sh
```
### Donation to my Smartcash please: SebFkuHrqDnj3obXvMtfxtQKRgFeVpXF5x
