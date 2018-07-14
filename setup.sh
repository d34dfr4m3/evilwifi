#!/bin/bash
function usage(){
	echo "Usage: 
		-w -> Wireless Interface to bind
		-n -> Wireless Network name"
}
function hostapd(){
	echo "[+] Setup HostAPD"
	if [ $(pidof hostapd) ];then
		echo "[!] Looks like Hostapd is already running at pid $(pidof hostapd)"
	elif [ -f conf/hostapd.conf ];then
		echo "[+] Starting hostapd"
		/usr/sbin/hostapd -Bdd conf/hostapd.conf
	else 
		echo "[!] Hostapd isn't running and the config file is missing"
	fi
}

function network(){
	echo "[+] Shutdown wlan0"
	ifconfig wlan0 down
	echo "[+] Setup wlan1 at /etc/network/interfaces"
	if [ $(grep -i wlan0 /etc/network/interfaces | wc -l ) -eq 0 ];then
		cat conf/wlan0.conf >> /etc/network/interfaces
	else
		echo "[-] Wlan1 already configured, but maybe wrong. Human, please check"
	fi
	echo "[+] Bring up wlan0"
	ifconfig wlan0 up
	echo "[+] Configuring Dnsmasq"
	cp conf/dnsmasq.conf /etc/dnsmasq.conf
	/etc/init.d/dnsmasq start
	echo "[+] Enabling routing"
	sysctl net.ipv4.ip_forward=1
}

function security(){
	echo "[+] Security: Firewall rules to isolate trafic cross networks"
	iptables -I FORWARD -i wlan0 -o wlan1 -j DROP
	iptables -I FORWARD -i wlan1 -o wlan0 -j DROP
	iptables -I FORWARD -i eth0 -o wlan0 -j DROP
	iptables -I FORWARD -i wlan0 -o eth0 -j DROP
	iptables -t nat -I PREROUTING -p tcp --dport 80 -j DNAT --to 192.168.8.1
	echo "	[*] Firewall Rules UP"
}

function webserver(){
	echo "[-] Check Nginx"
	if [ -n $(pidof nginx) ];then
		echo "[!] Looks like Nginx is running. Stopping NOW"
		systemctl stop nginx
	fi
	echo "[+] Configuring Nginx Virtual Hosts"
	rm -f /etc/nginx/sites-enabled/*
	if [ ! -d /var/www/nginx ];then
		mkdir /var/www/nginx
	fi
	for i in $(ls  conf/vhosts/*/*.conf);do
		FILENAME=$(echo $i | cut -d '/' -f4 )
		NAMEDIR=$(echo $i | cut -d '/' -f4 | cut -d '.' -f1)
		echo "	[*] Setup $FILENAME with domain $(grep server_name $i | cut -d ' ' -f 2) and DNS -> $(grep -i $NAMEDIR /etc/dnsmasq.conf | cut -d '/' -f 3 )"
		ln -s $(pwd)/$i /etc/nginx/sites-enabled/$FILENAME
		if [ ! -d /var/www/nginx/$NAMEDIR ];then
			mkdir /var/www/nginx/$NAMEDIR
			cp conf/vhosts/$NAMEDIR/index.* conf/vhosts/$NAMEDIR/*.php /var/www/nginx/$NAMEDIR/
		else
			echo "[!] Vhosts Directory already exists"
		fi
	done
	chown -R www-data.www-data /var/www/nginx
	echo "[+] starting php-fpm"
	/etc/init.d/php7.2-fpm start
	echo "[+] Starting Nginx"
	systemctl start nginx
}

while getopts w:s opt
do	case "$option" in
	w)	WFACE="$OPTARG";;
	n)	NETNAME="$OPTARG";;
	*)	usage
		exit 1;;
	esac
done
echo "[-] Starting Network Routine"
network
echo "[-] Starting Fake AP Routine"
hostapd
echo "[-] Starting Security Routine"
#security
echo "[-] Starting WebServer Routine"
webserver
