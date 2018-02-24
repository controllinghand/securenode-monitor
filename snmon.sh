#!/bin/bash 
# snmon.sh
# This script checks the health of all of your smartnode VPS

# get arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -v|--verbose)
    VFLAG="true"
    shift # past argument
    shift # past value
    ;;
    -i|--vpsip)
    VPSIP="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

#echo VFLAG = "${VFLAG}"
#echo VPSIP = "${VPSIP}"

if [[ -n $1 ]]; then
#    echo "Last line of file specified as non-opt/last argument:"
    echo "snmon.sh: illegal option $1"
    echo "usage snmon.sh [-v] [VPS IP]"
    exit -1
fi

#Set colors for easy reading. Unless your are color blind sorry for that
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
YEL='\033[0;33m'
NC='\033[0m' # No Color

# Check to see if the iplist file has any ip's for the VPSs
# Or check for a VPS IP past argument
if [[ $VPSIP ]]
then
    numips=$VPSIP
else
    numips=$(cat ~/snmon/iplist | grep -v "#" | wc -l)
    if [[ $numips -lt 1 ]]
    then
        echo "Please enter your VPS ip's into ~/snmon/iplist to begin"
        echo "exiting"
        exit -1
    fi
fi

# Add ssh-add so you don't have to type the passphrase for every VPS
sshcheck=$(ssh-add -L | grep -v "The agent has no identities")
if [[ ! $sshcheck ]]
then
    echo "Please enter in the ssh passphrase so you don't have to login for each node"
    echo "adding ssh-add"
    ssh-add
fi	

# Want to know when we ran this to check if data is stale
today=$(date)
todayUTC=$(date +%s)
echo "todays date:$today"

# Get the list of IP for all of our SmartNodes
if [[ $VPSIP ]]
then
    iplist=$VPSIP 
else
    iplist=$(cat ~/snmon/iplist | grep -v "#")
fi

#echo "$iplist"
for output in $iplist
# Let's walk through each SmartNode and start checking the health
do
    echo ""
    echo "SmartNode Check for IP:$output"

#
# Get data from VPS 
#
DATA=$(ssh -n smartadmin@$output 2>ssh.err cat /home/smartadmin/snmon/snmon.dat)

if [[ -s ssh.err ]]
then
    echo -en "[${RED}FAILED${NC}]No Data Found check monitoring agent on VPS"
    echo ""
    rm -f ssh.err
    continue 
fi

# check if data is stale over 20 minutes since last agent collected
vpsdate=$(echo "$DATA" | grep vpsdate | awk -F':' '{print $2}')
DIFF=$((todayUTC-vpsdate))

if [[ $DIFF -gt 72000 ]]
then
    echo -en "[${RED}FAILED${NC}]Data is older than 20mins check VPS"
    echo ""
    continue
fi

# Print out hostname
hostname=$(echo "$DATA" | grep hostname | awk -F':' '{print $2}')
if [[ ! $hostname ]]
then
    echo -en "[${RED}FAILED${NC}]no hostname found"
    echo ""
    continue
fi
if [[ $VFLAG ]];then 
    echo -en "[${GRN}OK${NC}]hostname: ${BLU}$hostname${NC}"
    echo ""
fi

# Check to see if smartcashd is running and by which user
smartcashduser=$(echo "$DATA" | grep smartcashduser | awk -F':' '{print $2}')
if [[ ! $smartcashduser ]]
then
    echo -en "[${RED}FAILED${NC}]smartcashd is not running"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]smartcashd: ${BLU}$smartcashduser${NC} is running the application"
        echo ""
    fi
fi

# Check smartnode status
smartnodestatus=$(echo "$DATA" | grep smartnodestatus | awk -F':' '{print $2}')
juststatus=$(echo $smartnodestatus | awk '{print $2}')
if [[  "$juststatus" != "successfully" ]]
then
    echo -en "[${RED}FAILED${NC}]smartcashd is not running"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]status: ${BLU}$smartnodestatus${NC}"
        echo ""
    fi
fi

# Check OS version 
osversion=$(echo "$DATA" | grep osversion | awk -F':' '{print $2}')
if [[ $VFLAG ]];then 
    echo -en "[${GRN}OK${NC}]OS: ${BLU}$osversion${NC}"
    echo ""
fi

# Check for OS packages are available for update
ospackagesneedupdate=$(echo "$DATA" | grep ospackagesneedupdate | awk -F':' '{print $2}')

if [[ $ospackagesneedupdate -gt 0 ]]; then
    echo -en "[${YEL}Warning${NC}]packages: ${BLU}$ospackagesneedupdate${NC} need updating for hostname ${BLU}$hostname${NC}"
    if [[ $VFLAG ]];then 
        echo ""
    fi
    WFLAG="true"
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]packages: ${BLU}0${NC} need updating"
        echo ""
    fi
fi

# Check smartcashd version 
smartcashdversion=$(echo "$DATA" | grep smartcashdversion | awk -F':' '{print $2}')
if [[ $VFLAG ]];then 
    echo -en "[${GRN}OK${NC}]smartcashd version: ${BLU}$smartcashdversion{NC}"
    echo ""
fi

# Check Disk Space 
currentdiskspaceused=$(echo "$DATA" | grep currentdiskspaceused | awk -F':' '{print $2}')
disknum=$(echo $currentdiskspaceused | awk -F'%' '{print $1}')
if [[  $disknum -gt 90 ]]
then
    echo -en "[${RED}FAILED${NC}] $currentdiskspaceused over 90% check VPS for disk space"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]current diskspace used%: ${BLU}$currentdiskspaceused${NC}"
        echo ""
    fi
fi

# Check ufw Firewall 
ufwstatus=$(echo "$DATA" | grep ufwstatus | awk -F':' '{print $3}')
if [[  "$ufwstatus" != " active" ]]
then
    echo -en "[${RED}FAILED${NC}]firewall is not active"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]firewall status: ${BLU}$ufwstatus${NC}"
        echo ""
    fi
fi

# Check ufw Firewall ssh
ufwssh=$(echo "$DATA" | grep ufwssh | awk -F':' '{print $2}')
if [[  "$ufwssh" != "LIMIT" ]]
then
    echo -en "[${RED}FAILED${NC}]check firewall ssh 22 port settings"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]firewall ssh 22: ${BLU}$ufwssh${NC}"
        echo ""
    fi
fi

# Check ufw Firewall smartcashd port 9678
ufwscport=$(echo "$DATA" | grep ufwscport | awk -F':' '{print $2}')
if [[  "$ufwscport" != "ALLOW" ]]
then
    echo -en "[${RED}FAILED${NC}]check firewall smartcashd 9768 port settings"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]firewall smartcashd 9768: ${BLU}$ufwscport${NC}"
        echo ""
    fi
fi

# Check ufw Firewall if any other ports are open 
ufwother=$(echo "$DATA" | grep ufwother | awk -F':' '{print $2}')
if [[ "$ufwother" != "none" ]]
then
    echo -en "[${RED}FAILED${NC}]$ufwother is open please close"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]firewall any other open: ${BLU}$ufwother${NC}"
        echo ""
    fi
fi

# Check crontab jobs 
# Check for makerun.sh  
makerun=$(echo "$DATA" | grep makerun | awk -F':' '{print $2}')
if [[ ! $makerun ]]
then
    echo -en "[${RED}FAILED${NC}]makerun cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]makerun cronjob: ${BLU}$makerun${NC}"
        echo ""
    fi
fi

# Check for checkdaemon.sh  
checkdaemon=$(echo "$DATA" | grep checkdaemon | awk -F':' '{print $2}')
if [[ ! $checkdaemon ]]
then
    echo -en "[${RED}FAILED${NC}]checkdaemon cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]checkdaemon cronjob: ${BLU}$checkdaemon${NC}"
        echo ""
    fi
fi

# Check for upgrade.sh  
upgrade=$(echo "$DATA" | grep upgrade | awk -F':' '{print $2}')
if [[ ! $upgrade ]]
then
    echo -en "[${RED}FAILED${NC}]upgrade cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]upgrade cronjob: ${BLU}$upgrade${NC}"
        echo ""
    fi
fi

# Check for clearlog.sh  
clearlog=$(echo "$DATA" | grep clearlog | awk -F':' '{print $2}')
if [[ ! $clearlog ]]
then
    echo -en "[${RED}FAILED${NC}]clearlog cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]clearlog cronjob: ${BLU}$clearlog${NC}"
        echo ""
    fi
fi

# Check for snmonagent.sh  
snmonagent=$(echo "$DATA" | grep snmonagent | awk -F':' '{print $2}')
if [[ ! $snmonagent ]]
then
    echo -en "[${RED}FAILED${NC}]snmonagent cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]snmonagent cronjob: ${BLU}$snmonagent${NC}"
        echo ""
    fi
fi

if [[ ! $VFLAG ]]  || [[ $VPSIP ]] && [[ ! $WFLAG ]]
then
    echo -en "[${GRN}OK${NC}]${BLU}$hostname${NC}"
else
    if [[ $VFLAG ]]
    then
        echo ""
    fi
fi

WFLAG=""

done

echo ""
