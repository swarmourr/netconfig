#!/bin/bash
echo "---------------------------------------------------------------------------------------------------------------------------------- _           

//        ___           ___                         ___           ___           ___           ___                       ___     
//       /\  \         /\__\                       /\__\         /\  \         /\  \         /\__\                     /\__\    
//       \:\  \       /:/ _/_         ___         /:/  /        /::\  \        \:\  \       /:/ _/_       ___         /:/ _/_   
//        \:\  \     /:/ /\__\       /\__\       /:/  /        /:/\:\  \        \:\  \     /:/ /\__\     /\__\       /:/ /\  \  
//    _____\:\  \   /:/ /:/ _/_     /:/  /      /:/  /  ___   /:/  \:\  \   _____\:\  \   /:/ /:/  /    /:/__/      /:/ /::\  \ 
//   /::::::::\__\ /:/_/:/ /\__\   /:/__/      /:/__/  /\__\ /:/__/ \:\__\ /::::::::\__\ /:/_/:/  /    /::\  \     /:/__\/\:\__\
//   \:\~~\~~\/__/ \:\/:/ /:/  /  /::\  \      \:\  \ /:/  / \:\  \ /:/  / \:\~~\~~\/__/ \:\/:/  /     \/\:\  \__  \:\  \ /:/  /
//    \:\  \        \::/_/:/  /  /:/\:\  \      \:\  /:/  /   \:\  /:/  /   \:\  \        \::/__/       ~~\:\/\__\  \:\  /:/  / 
//     \:\  \        \:\/:/  /   \/__\:\  \      \:\/:/  /     \:\/:/  /     \:\  \        \:\  \          \::/  /   \:\/:/  /  
//      \:\__\        \::/  /         \:\__\      \::/  /       \::/  /       \:\__\        \:\__\         /:/  /     \::/  /   
//       \/__/         \/__/           \/__/       \/__/         \/__/         \/__/         \/__/         \/__/       \/__/    
--------------------------------------------------------------------------------------------------------------swarmourr © 2018 --- "
static(){

echo " configuration des interfaces avec un ip static "
int_name=$(ls /sys/class/net/|cut -d" " -f 1 | head -1)
echo " on va configuré l'interface $int_name "
echo " setting $int_name up "
ip link set dev lo up
echo "entrez address ip "
read ip 
echo "entrez le mask " 
read mask
echo "entrez la passrelle " 
read pass
echo " # This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback" > interfaces
echo >> interfaces
echo allow-hotplug $int_name  >> interfaces
echo iface $int_name inet static >> interfaces
echo   address $ip >> interfaces 
echo   netmask $mask >> interfaces
echo   gateway $pass >> interfaces

file1=/etc/network/interfaces
echo $file1

if [ -e "$file1" ]
then
  mv /etc/network/interfaces /etc/network/interfaces.old
  cp interfeces  /etc/network/
fi
ip addr flush dev $int_name
/etc/init.d/networking restart
echo " au cas d'absence des modifs veillez redemarrer votre system " 

}

gw(){

echo " configuration interfaces de serveur de la gateway "

echo " entrez le nombre des interfaces de la gateway "
read nmbr 
cp interfaces /tmp/interfaces

for i in $(seq 1 $nmbr)
do
 echo " entrez le nom de l'interface $i " 
 read int_name
 echo " on va configuré l'interface $int_name "
 echo " setting $int_name up "
 ip link set dev $int_name up

 echo "entrez address ip "
 read ip 
 echo "entrez le mask " 
 read mask
 echo "entrez la passrelle " 
 read pass
 echo " # This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback" > interfaces
 echo >> interfaces
 echo allow-hotplug $int_name  >> interfaces
 echo iface $int_name inet static >> interfaces
 echo   address $ip >> interfaces 
 echo   netmask $mask >> interfaces
 echo   gateway $pass >> interfaces

done 

file1=/etc/network/interfaces
echo $file1

if [ -e "$file1" ]
then
  mv /etc/network/interfaces /etc/network/interfaces.old
  cp interfeces  /etc/network/
fi

for i in $(ls /sys/class/net/) ; do
    /usr/sbin/ip addr flush $i &
done

echo " activing the forwading "

echo 1 > /proc/sys/net/ipv4/ip_forward

echo " redemarrage des services "
/etc/init.d/networking restart

echo " au cas d'absence des modifs veillez redemarrer votre system " 
}

dhcp(){

echo " configuration interfaces de serveur dhcp "
static
int_name=$(ls /sys/class/net/|cut -d" " -f 1 | head -1)

echo "default-lease-time 600;" >dhcpd.conf
echo "max-lease-time 7200;" >>dhcpd.conf

echo " entrez addresse reseaux  et net-mask "
read ip mask
echo "entrez le range "
read r1 r2
echo "entrez passerelle et broadcast "
read pass broad

echo >>dhcpd.conf
echo subnet $ip netmask $mask { >>dhcpd.conf
echo   "range $r1 $r2;" >>dhcpd.conf
echo   "option domain-name-servers ns1.internal.example.org;">>dhcpd.conf
echo   "#option domain-name "internal.example.org";">>dhcpd.conf
echo   "#option routers $pass;">> /tmp/dhcpd.conf >>dhcpd.conf
echo   "option broadcast-address $broad;">>dhcpd.conf
echo   "default-lease-time 600;">>dhcpd.conf
echo   "max-lease-time 7200;">>dhcpd.conf
echo }>>dhcpd.conf

echo >>dhcpd.conf

echo " veux tu fixer ip d'une machine o/n "
read choix 
case $choix in 
	o ) echo "entrez le nom du machine "
	    read mach
            ping -c 3 $mach
	    if [ $? -eq 0 ]
            then
		echo " donnez addresse ip "
		read ho
		echo host $mach {>>dhcpd.conf
		 echo "hardware ethernet $(arp -a |grep $mach |awk '{printf $4 }') ;">> dhcpd.conf
		 echo "fixed-address $ho;" >> dhcpd.conf
                 echo }>>dhcpd.conf
		 
		
	    else echo "hote n'existe pas dans le reseau verfier le nom "

	    fi
	 ;;
		 
	n ) ;;
esac
file1=/etc/dhcp/dhcpd.conf
echo $file1

if [ -e "$file1" ]
then
  mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old
  cp dhcpd.conf  /etc/dhcp/
else 
  cp dhcpd.conf  /etc/dhcp/
fi

file2=/etc/default/isc-dhcp-server
if [ -e "$file2" ]
then
  mv /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.old
  echo INTERFACESv4="\"$int_name\"" >isc-dhcp-server
  cp isc-dhcp-server /etc/default
else 
 echo INTERFACESv4="\"$int_name\"" > isc-dhcp-server
  cp isc-dhcp-server    /etc/default
fi

/etc/init.d/isc-dhcp-server restart

}

relay(){

echo "configuration du relay"
cp isc-dhcp-relay /tmp/

echo " entrez les interfaces des serveur relay "
read int

echo " entrez les addresses ip des serveur dhcp "
read ip

echo SERVERS= \"$ip\">isc-dhcp-relay
echo INTERFACES=\"$int\" >>isc-dhcp-relay
file=/etc/default/isc-dhcp-relay

if [ -e "$file" ]
then
  mv /etc/default/isc-dhcp-relay /etc/default/isc-dhcp-relay.old
  cp isc-dhcp-relay /etc/default/
else 
  cp isc-dhcp-relay /etc/default/
fi

echo " forwading activitaion "
echo 1 > /proc/sys/net/ipv4/ip_forward
echo " done "

/etc/init.d/isc-dhcp-relay restart

}


echo " choisissez le numero de la configuration "
echo  " 1 - static "
echo  " 2 - gw "
echo  " 3 - dhcp "
echo  " 4 - relay "
echo  " 5 - quitter"
read a

case $a in 


	1 ) static ;;
	2 ) gw ;;
	3 ) dhcp ;;
	4 ) relay;;
	5 ) exit 0;;
	* ) echo "retry next time"

esac
	
 
