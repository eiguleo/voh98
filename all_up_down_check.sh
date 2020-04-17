#!/bin/bash

#Get Network Interface Card
getNetInfo(){
lspci  | grep -i "ethernet"
#single Network Interface Card
uuid=$(nmcli -f UUID  connection  show | sed -n '2,$p')
echo $uuid

#https://developer.gnome.org/NetworkManager/unstable/nm-settings.html
nmcli connection show uuid $uuid | grep -v "\-\-"

#nmcli connection down $uuid

#nmcli connection up   $uuid
}


#replace the last charactor
#sed  's/\(.*\)\(.\)/\12/g'  tmp

# get nic status  , resullt link "enp2s0 1"
getNicStatus(){
    nmcli  -f  DEVICE  connection | awk 'NR>1{print $0,1}' > /tmp/nic_status
    }

# up all Nic
upAllNic(){
for uuidd in `nmcli -m multiline  -f UUID connection | awk '{print $2}'` ; do nmcli connection up uuid $uuidd   ; done
   sed -i  's/\(.*\)\(.\)/\11/g'  /tmp/nic_status  
}

downAllNic(){
    for uuidd in `nmcli -m multiline  -f UUID connection | awk '{print $2}'` ; do nmcli connection down uuid $uuidd   ; done
    sed -i  's/\(.*\)\(.\)/\10/g'  /tmp/nic_status
}

checkDownNic(){
    devname=$1
    #nmcli connection down   $uuid
    ping -c 2 -w 5 47.56.88.11 > /dev/null 2>&1
    if [ $? == 0 ]; then
	echo "ping success,checkresult Faild"
	return 3
    else
	echo "ping failed,check result  Through"
	return 0
    fi
}

checkUpNic(){
    devname=$1
    #nmcli connection up $uuid
    ping -c 2 -w 5 47.56.88.11 -I $devname  > /dev/null 2>&1
    if [ $? != 0 ]; then
	echo "Ping Faild,check result-----faild"
	return 3
    else
	echo "Ping success,check result----through"
	return 0
    fi
    
}



checkNic(){
    devname=$1
    status=$2

    if [ "$status" == 1 ]; then
	echo -e "\r\nnic status is up, entry up check"
	checkUpNic $devname
    else
	echo -e "\r\nnic status is down, entry down check"
	checkDownNic $devname
    fi    

}

getNicStatus
downAllNic
while read ln ; do checkNic $ln ;done < /tmp/nic_status
upAllNic
while read ln ; do checkNic $ln ; done < /tmp/nic_status
#up or down  all the nic one by one
