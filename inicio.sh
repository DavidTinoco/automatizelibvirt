#! /bin/bash

virsh net-start br1
virsh start mv1

sleep 10

ip1=`virsh net-dhcp-leases br1 | grep mv1 | tr -s " " | cut -d " " -f 6 | cut -d "/" -f 1`

virsh attach-device mv1 /etc/libvirt/storage/apache.xml

vd1=`ssh -i /home/david/.ssh/jupiter root@$ip1 lsblk | grep -v 'vda' | grep ^vd | tr -s " " | cut -d " " -f 1`

ssh -i /home/david/.ssh/jupiter root@$ip1 mount /dev/$vd1 /var/www/html

iptables -I FORWARD -d $ip1/32 -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to $ip1
