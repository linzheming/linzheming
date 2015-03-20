#!/bin/sh
# 用户查找设备节点到实际硬件接口的映射 如 sda -> 1  sdb -> 2 ,工厂测试使用.
# create devices_mapping file
# e.g.  sda  1
# TODO /sys/class/scsi_host/host0/device/target0\:1\:0/0\:1\:0\:0/block/sda  maybe 
# Host:Bus:Target:LUN

devices_mapping='devices_mapping'
test -e $devices_mapping && echo "rm old" $devices_mapping && rm $devices_mapping

host_num=0
#总共几个控制器
total_host_num=`ls /sys/class/scsi_host  | wc -w`
#每个控制器有几个接口
host_ports=5

while [ $host_num -lt $total_host_num ]
do
	for basedir in "/sys/class/scsi_host/host$host_num"
	do
		for targetHBT in $( ls "$basedir/device/" | grep "target")                             
		do   
			echo $targetHBT
	        HBT=$(echo $targetHBT | cut -c 7-)                   
			echo "HBT is" $HBT
            T=$(echo $HBT | cut -c 5)
            B=$(echo $HBT | cut -c 3)
            echo $T
	        for device in $(ls $basedir/device/$targetHBT/$HBT:0/block/)
	        do                         
	        	if [ -n $device ]
	            then          
						B=$((B+host_num*host_ports))
						echo $device $B  >> $devices_mapping
	            fi   
	            break
	        done
		done
	done
	host_num=$((host_num+1))
done


