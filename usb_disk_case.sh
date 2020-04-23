#!/bin/sh


#if  mount point not exist, then create
[ ! -e /opt/uos_mount ] && mkdir -p /opt/uos_mount

#get current usb device list
#lsblk -d -x NAME| awk 'NR>1{print $1}' > ./current_block_devices
getCurrentDiskPartions(){
    lsblk -J | jq ".blockdevices" | jq ".[]|.children" | jq ".[]|.name" | tr -d "\"" > ./current_disk_partions
}

getCurrentBlockDevices(){
lsblk -d -x NAME| awk 'NR>1{print $1}' > ./current_block_devices
}

checkOneMount(){
    partion=$1
    mount /dev/$partion /opt/uos_mount/$partion
    if [ $? == 0 ];then
	echo "Mount check ---- Though"
    else
	echo "Mount check ---- Faild"
    fi    
}

checkOneUmount(){
    partion=$1
    umount /dev/$partion
    if [ $? == 0 ]; then
	echo "Umount check ---- Though"
    else
	echo "Umount check ---- Faild"
    fi
}

delOnePartion(){
    devname=$1
    sfdisk --delete /dev/$devname
}

umoutAllPartions(){
    for ln in `comm -3 current_disk_partions  origin_disk_partions` ; do umount /dev/$ln; done 
}


#mount all usb disk
checkAllMount(){
    rm -rf /opt/uos_mount/*
    for ln in `comm -3 current_disk_partions origin_disk_partions`
    do
	mkdir -p /opt/uos_mount/$ln
	checkOneMount $ln /opt/uos_mount/$ln
    done
}

checkAllUmount(){
    for ln in `comm -3 current_disk_partions origin_disk_partions` ; do checkOneUmount $ln; done
}




delAllPartions(){
    for disk in `comm -3 current_block_devices origin_block_devices` ; do delOnePartion $disk ; done
}



checkCreateOnePartion(){
    disk=$1
    sfdisk  /dev/$1 <<EOF
,,L

EOF
    if [ $? == 0 ] ; then
	echo "check mkpart ---- Though"
    else
	echo "check mkpart ---- Faild"
    fi
    
}
checkCreateAllPartions(){
    for part in `comm -3 current_block_devices origin_block_devices`; do  checkCreateOnePartion $part;done
}
checkMkfsOnePartion(){

    partion=$1
    mkfs.xfs -f  /dev/$partion
    if [ $?==0 ];then
	echo "mkfs check ---- Through"
    else
	echo "mkfs check ---- Faild"
    fi
    
    }
    
checkAllMkfsPartions(){
    for part in `comm -3 current_disk_partions origin_disk_partions`; do  checkMkfsOnePartion $part;done
    
    }



getCurrentBlockDevices
getCurrentDiskPartions
umoutAllPartions
delAllPartions
checkCreateAllPartions
getCurrentDiskPartions
checkAllMkfsPartions
checkAllMount
