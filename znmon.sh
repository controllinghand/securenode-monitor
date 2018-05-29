#!/bin/bash 
# znmon.sh
# This script checks the health of all of your securenode VPS

# As for 5/28/2018 the Protocol version should be 2001150
CURPROTOCOLVER='2001150'

#Set colors for easy reading. Unless your are color blind sorry for that
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
YEL='\033[0;33m'
NC='\033[0m' # No Color

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
    echo "znmon.sh: illegal option $1"
    echo "usage znmon.sh [-v] [VPS IP]"
    exit -1
fi



# Check to see if the iplist file has any ip's for the VPSs
# Or check for a VPS IP past argument
if [[ $VPSIP ]]
then
    numips=$VPSIP
else
    numips=$(cat ~/znmon/iplist | grep -v "#" | wc -l)
    if [[ $numips -lt 1 ]]
    then
        echo "Please enter your VPS ip's into ~/znmon/iplist to begin"
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

# Get the list of IP for all of our SecureNodes
if [[ $VPSIP ]]
then
    iplist=$VPSIP 
else
    iplist=$(cat ~/znmon/iplist | grep -v "#")
fi

#echo "$iplist"
for output in $iplist
# Let's walk through each SecureNode and start checking the health
do
    echo ""
    echo "SecureNode Check for IP:$output"

#
# Get data from VPS 
#
DATA=$(ssh -n zenadmin@$output 2>ssh.err cat /home/zenadmin/znmon/znmon.dat)

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

# Print out hostname (Row 1)
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

# Check to see if zend is running and by which user (Row 2)
zenduser=$(echo "$DATA" | grep zenduser | awk -F':' '{print $2}')
if [[ ! $zenduser ]]
then
    echo -en "[${RED}FAILED${NC}]zend is not running"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]zend: ${BLU}$zenduser${NC} is running the application"
        echo ""
    fi
fi

# Check Challenge Balance (Row 3)
znbalance=$(echo "$DATA" | grep znbalance | awk -F':' '{print $2}')
if [[  $znbalance -lt .4 ]]
then
    echo -en "[${RED}FAILED${NC}] $znbalance under .4 send zencash private to xyz"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]current balance: ${BLU}$znbalance${NC}"
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
    echo ""
    WFLAG="true"
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]packages: ${BLU}0${NC} need updating"
        echo ""
    fi
fi

# Check zend protocol version 
zendversion=$(echo "$DATA" | grep zendversion | awk -F':' '{print $2}')
if [[ $zendversion != "$CURPROTOCOLVER" ]];then
    echo -en "[${RED}FAILED${NC}] $zendversion should be at $CURPROTOCOLVER"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]zend version: ${BLU}$zendversion${NC}"
        echo ""
    fi
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
# Check for acme.sh  
acme=$(echo "$DATA" | grep acme | awk -F':' '{print $2}')
if [[ ! $acme ]]
then
    echo -en "[${RED}FAILED${NC}]acme cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]acme cronjob: ${BLU}$acme${NC}"
        echo ""
    fi
fi

# Check for znmonagent.sh  
znmonagent=$(echo "$DATA" | grep znmonagent | awk -F':' '{print $2}')
if [[ ! $znmonagent ]]
then
    echo -en "[${RED}FAILED${NC}]znmonagent cron job missing"
    echo ""
else
    if [[ $VFLAG ]];then 
        echo -en "[${GRN}OK${NC}]znmonagent cronjob: ${BLU}$znmonagent${NC}"
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
