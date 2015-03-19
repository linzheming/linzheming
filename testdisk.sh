#!/bin/sh
# 用户查找设备节点到实际硬件接口的映射 如 sda -> 1  sdb -> 2 ,工厂测试使用.
# create devices_mapping file
# e.g.  sda  1
# TODO /sys/class/scsi_host/host0/device/target0\:1\:0/0\:1\:0\:0/block/sda  maybe 
# Host:Bus:Target:LUN

devices_mapping='devices_mapping'
test -e $devices_mapping && echo "rm old" $devices_mapping && rm $devices_mapping

host_num=0
host_num_all=2
while [ $host_num -lt $host_num_all ]
do
	for basedir in "/sys/devices/platform/sata_mv.0/host$host_num"
	do
		for target in $( ls $basedir | grep target)                             
		do   
			echo $target
	        interfaceno=$(echo $target | cut -d ':' -f 2)                   
			echo $interfaceno
	        for basename in $(ls $basedir/$target/$host_num:$interfaceno:0:0/block/)
	        do                         
	        	if [ -n $basename ]
	            then          
						interfaceno=$((interfaceno+host_num*5))
						echo $basename $interfaceno  >> $devices_mapping
	            fi   
	            break
	        done
		done
	done
	host_num=$((host_num+1))
done


