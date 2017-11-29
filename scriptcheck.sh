#! /bin/bash

stat1=`virsh list --all | grep mv1 | tr -s " " | cut -d " " -f 4`
stat2=`virsh list --all | grep mv2 | tr -s " " | cut -d " " -f 4`

if [[ $stat1 == 'running' ]]
then
	ip1=`virsh net-dhcp-leases br1 | grep mv1 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`

	memava=`ssh -i /home/david/.ssh/jupiter root@$ip1 cat /proc/meminfo | grep MemAvailable | tr -s " " | cut -d " " -f 2`

	if [[ $memava -lt "30000" ]]
	then
		echo "Cambiando de máquina"
		bash /home/david/Documentos/ASIR/Segundo/HLC/libvirt/script.sh
	fi

elif [[ $stat2 == 'running' ]]
then
	ip2=`virsh net-dhcp-leases br1 | grep mv2 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`

	memava2=`ssh -i /home/david/.ssh/jupiter root@$ip2 cat /proc/meminfo | grep MemAvailable | tr -s " " | cut -d " " -f 2`
	
	if [[ $memava2 -lt "60000" ]]
	then
		echo "Aumentando la memoria"
		virsh setmem mv2 2G --live
	fi

fi
