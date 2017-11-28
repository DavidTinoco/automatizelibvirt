#! /bin/bash

#Arrancamos mv2 (si está arrancada virsh nos dirá que ya lo está)
virsh start mv2
sleep 10

#Guardamos la ip de la máquina mv1 y el nombre del dispositivo que tiene nuestro volúmen dentro de la máquina
ip1=`virsh net-dhcp-leases br1 | grep mv1 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`
vd1=`ssh -i /home/david/.ssh/jupiter root@$ip1 lsblk | grep -v 'vda' | grep ^vd | tr -s " " | cut -d " " -f 1`

#Desmontamos el volumen
ssh -i /home/david/.ssh/jupiter root@$ip1 umount /dev/$vd1

#Y lo desconectamos
virsh detach-device mv1 /etc/libvirt/storage/apache.xml

#########################################
#Redimensionado del volumen
lvresize -L +10M /dev/sistema/mv1
mount /dev/sistema/mv1 /mnt
xfs_growfs /dev/sistema/mv1
umount /mnt
#########################################

#Guardamos la ip de la máquina mv2
ip2=`virsh net-dhcp-leases br1 | grep mv2 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`

#Conectamos el volumen a mv2
virsh attach-device mv2 /etc/libvirt/storage/apache.xml

#Y guardamos el nombre del dispositivo que tiene nuestro volúmen dentro de la máquina
vd2=`ssh -i /home/david/.ssh/jupiter root@$ip2 lsblk | grep -v 'vda' | grep ^vd | tr -s " " | cut -d " " -f 1`

#Para montarlo a continuación
ssh -i /home/david/.ssh/jupiter root@$ip2 mount /dev/$vd2 /var/www/html

#""""Parseamos"""" la línea en la que se encuentra nuestra actual regla de iptable para el acceso a nuestra web
line=`iptables -t nat -L --line-number | grep $ip1 | cut -d " " -f 1`

#Y la eliminamos
iptables -t nat -D PREROUTING $line

#Para a continuación añadir la nueva regla hacia mv2
iptables -I FORWARD -d $ip2/32 -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to $ip2

#Apagamos mv1
virsh shutdown mv1

