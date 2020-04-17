#!/bin/bash

#test the performence when up and down nic 
#1,up all nic,and get nic info like  c4b34234-7690-1497-5700-384cb5932da7  enp2s0  1 into file nic_status_uuid
#2,for each line in nic_status_uuid, up the nic and generate  line with status 0 or 1, check whether the ping result aggrees with the status line





#getNicInfo get uuid devname info of nic into file nic_status_uuid
#uuid                                  device  status
#c4b34234-7690-1497-5700-384cb5932da7  enp2s0  1
#c4b34234-7690-1497-5700-fdffb5932da8  enp3s0  0
#c4b34234-7690-1497-5700-384cbsdfsda9  enp4s0  0
getNicInfo(){
    nmcli  -f  UUID,DEVICE  connection | awk 'NR>1{print $0,1}' > ./nic_status_uuid
    }

#up all nic ,and set nic status to 1
upAllNic(){
for uuidd in `nmcli -m multiline  -f UUID connection | awk '{print $2}'` ; do nmcli connection up uuid $uuidd   ; done
   sed -i  's/\(.*\)\(.\)/\11/g'  ./nic_status_uuid
}


#down all nic, and set nic status to 0
downAllNic(){
    for uuidd in `nmcli -m multiline  -f UUID connection | awk '{print $2}'` ; do nmcli connection down uuid $uuidd   ; done
    sed -i  's/\(.*\)\(.\)/\10/g'  ./nic_status_uuid
}

checkDownNic(){
    devname=$2
    #nmcli connection down   $uuid
    ping -c 2 -w 5 47.56.88.11 -I $devname > /dev/null 2>&1
    if [ $? == 0 ]; then
	echo "ping success,checkresult Faild"
	return 3
    else
	echo "ping failed,check result  Through"
	return 0
    fi
}

checkUpNic(){
    devname=$2
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

#downAllNic
#while read ln ; do checkNic $ln ;done < /tmp/nic_status
#upAllNic

#while read ln ; do checkNic $ln ; done < /tmp/nic_status

#up the nic its uuid is $uuid
upOneNic(){
    uuid=$1
    nmcli con up uuid $uuid
    
}

#set the nic whose uuid is $uuid
downOneNic(){
    uuid=$1
    nmcli con  down  uuid $uuid
}

nmcli -m multiline  -f UUID connection | awk '{print $2}' > uuidset

#for uuid in uuidset;do  upOneNic $uuid ; get_devname_by $uuid ; checkNic $devname ; downOneNic $uuid ; checkNic $devname;done
#for uuid in ; do  upOneNic $uuid ; get_devname_by $uuid ; checkNic $devname ;done


#get devnmame by uuid
getDevByUuid(){
    uuid=$1
    
    devname=$(grep $uuid nic_status_uuid | awk '{print $2}')
    echo "$devname"
}


#for uuid in `nmcli -m multiline  -f UUID connection | awk '{print $2}'`
#do
#    devn=$(getDevByUuid $uuid)
#    echo "$devn"
#    upOneNic $uuid
#    checkNic $devn
    
#done

#step 1
getNicInfo

#step 2
#read line , set status field in the line , check the wether the status agree with ping result 

while read line
do
    #echo $lin 
    upStatusLine=`echo $line | sed  "s/\(.*\)\(.\)/\11/g"`
    echo $upStatusLine
    #getDevByUuid $line
    upOneNic $upStatusLine
    checkUpNic $upStatusLine
    #echo $upState
    downStatusLine=`echo $line | sed  "s/\(.*\)\(.\)/\10/g"`
    downOneNic $downStatusLine
    checkDownNic $downStatusLine
    #cat nic_status_uuid
    #echo -e "-------------"
    #downOneNic $line
    #checkUpNic $
    #cat nic_status_uuid
    echo -e "max loop ###########\r\n\r\n"
    
done < nic_status_uuid


upAllNic
