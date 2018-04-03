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
-------------------------------------------------------------------------------------------------------------------swarmourr © 2018---------"
debian(){
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
  cp interfaces  /etc/network/
else
  cp interfaces  /etc/network/
fi
ip addr flush dev $int_name
/etc/init.d/networking restart
echo " au cas d'absence des modifs veillez redemarrer votre system " 

}

gw(){

echo " configuration interfaces de serveur de la gateway "

echo " entrez le nombre des interfaces de la gateway "
read nmbr 

 echo " # This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback" > interfaces

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
  cp interfaces  /etc/network/
else
  cp interfaces  /etc/network/
fi

for i in $(ls /sys/class/net/) ; do
    ip addr flush $i &
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
echo " entrez nombre des ranges"
read i 
for j in $(seq 1 $i)
do
echo " entrez addresse reseaux  et net-mask du range $i :"
read ip mask
echo "entrez le range du range $i : "
read r1 r2
echo "entrez passerelle et broadcast du range $i : "
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
done

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

gw

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

route(){

echo "tu veux 1-ajouter ou 2-supprimer 1/2"
read choix 

case $choix in

	1 )  echo " Ajouter une nouvelle route "
	    echo " entrer l'addresse ip "
	    read ip
            echo " entrer le mask "
            read mask
            echo " la passrelle"
            read pass
            echo " entrez m'interface"
            read int
	    route add -net $ip netmask $mask gw $pass dev $int
	    echo "la table de routage "
	    route -n
;;

	2 )  echo " Supprimer une route "
	    echo " entrer l'addresse ip "
	    read ip
            echo " entrer le mask "
            read mask
            echo " la passrelle"
            read pass
            echo " entrez m'interface"
            read int
	    route del -net $ip netmask $mask gw $pass dev $int
	    echo " la table de routage "
	    route -n 
;;

	 * ) echo " choisir 1 ou 2 " 
	     route
;;
esac
}

forwading(){

echo " activing the forwading "

echo 1 > /proc/sys/net/ipv4/ip_forward

}

nis(){

echo " cofigurations   nis "
echo " choisissez le numero de la configuration "
echo  " 1 - serveur "
echo  " 2 - client  "
read op
serv(){
static 
echo " configuration serveur nis  "
dpkg-reconfigure nis

file=/etc/default/nis

if [ -e "$file" ]
then
  mv /etc/default/nis /etc/default/nis.old
  cp nis /etc/default/
else 
  cp nis /etc/default/
fi
/etc/init.d/nis start
echo " entrez le mask et addresse reseaux des client accessible"
read ip 
file1= /etc/ypserver.securenets 
if [ -e "$file1" ]
then
  echo $ip >> /etc/ypserver.securenets 
else 
  echo $ip >> ypserver.securenets
  cp ypserver.securenets /etc
fi

service nis restart 
/usr/lib/yp/ypinit -m 
cd /var/yp
make
}

clt(){
echo  " configuration client nis "
echo " entrez addresse ip de serveur "
read ip_serveur
files= /etc/yp.conf
if [ -e "$files" ]
then
  echo ypserver $ip >> /etc/yp.conf
else 
  echo $ip >> yp.conf
  cp yp.conf /etc
fi
file2= /etc/nsswitch.conf
if [ -e "$file2" ]
then
  mv /etc/nsswitch.conf /etc/nsswitch.conf.old
  cp nsswitch.conf /etc/
else 
  echo $ip >> yp.conf
  cp yp.conf /etc
fi
file=/etc/default/nis

if [ -e "$file" ]
then
  mv /etc/default/nis /etc/default/nis.old
  cp nis_client /etc/default/nis
else 
   cp nis_client /etc/default/nis
fi

/usr/lib/yp/ypint -s $ip
}
 
case $op in 

	1 ) serv ;;
	2 ) clt ;;


esac
}

echo " choisissez le numero de la configuration "
echo  " 1 - static "
echo  " 2 - gw "
echo  " 3 - dhcp "
echo  " 4 - relay "
echo  " 5 - ajouter une route"
echo  " 6 - activer le routage"
echo  " 7 - nis"
echo  " 8 - quitter"
read a

case $a in 

	1 ) static ;;
	2 ) gw ;;
	3 ) dhcp ;;
	4 ) relay;;
	5 ) route;;
	6 ) forwading;;
	7 ) nis;;
	8 ) exit 0;;
	* ) echo "retry next time"

esac
}

redhat(){

echo "bienvenue dans le redhat"
echo " ca " 

}


echo " choisir la famille 1- debian   2- redhat "
read i

case $i in 

	1 ) debian;;

	2 ) redhat ;;
	
	* ) echo "desolé juste linux "

esac
