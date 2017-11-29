#! /bin/bash

bash /home/david/Documentos/ASIR/Segundo/HLC/libvirt/inicio.sh

stat1=`virsh list --all | grep mv1 | tr -s " " | cut -d " " -f 4`
stat2=`virsh list --all | grep mv2 | tr -s " " | cut -d " " -f 4`

statmem1='ok'
statmem2='ok'

ip1=`virsh net-dhcp-leases br1 | grep mv1 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`

while [[ $statmem1 == 'ok' ]]; do

	memava=`ssh -i /home/david/.ssh/jupiter root@$ip1 cat /proc/meminfo | grep MemAvailable | tr -s " " | cut -d " " -f 2`

	if [[ $memava -lt "30000" ]]
	then

		sleep 10

		memava=`ssh -i /home/david/.ssh/jupiter root@$ip1 cat /proc/meminfo | grep MemAvailable | tr -s " " | cut -d " " -f 2`

		if [[ $memava -lt "30000" ]]
		then

			echo "Cambiando de máquina"

			bash /home/david/Documentos/ASIR/Segundo/HLC/libvirt/script.sh

			statmem1='bad'
		fi
	fi

done

ip2=`virsh net-dhcp-leases br1 | grep mv2 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`

while [[ $statmem2 == 'ok' ]]; do
	
	memava=`ssh -i /home/david/.ssh/jupiter root@$ip2 cat /proc/meminfo | grep MemAvailable | tr -s " " | cut -d " " -f 2`
	
	if [[ $memava -lt "60000" ]]
	then

		sleep 10

		memava=`ssh -i /home/david/.ssh/jupiter root@$ip2 cat /proc/meminfo | grep MemAvailable | tr -s " " | cut -d " " -f 2`

		if [[ $memava -lt "60000" ]]
		then

			echo "Aumentando la memoria"

			virsh setmem mv2 2G --live

			statmem2='aumented'
		fi

	fi
done
