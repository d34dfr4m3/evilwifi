#!/bin/bash
#set -x
function hostapd(){
	echo "[+] Setup HostAPD"
	if [ -n $(pidof hostapd) ];then
		echo "[!] Looks like Hostapd is already running at pid $(pidof hostapd)"
	elif [ -f conf/hostapd.conf ];then
		echo "[+] Starting hostapd"
		hostapd -Bdd conf/hostapd.conf
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
	iptables -t nat -I PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to 80
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
	for i in $(ls conf/vhosts/);do
		echo "	[*] Setup $i"
		ln -s $(pwd)/conf/vhosts/$i /etc/nginx/sites-enabled/$i
		if [ ! -d /var/www/$i ];then
			mkdir /var/www/nginx/$i
		else
			echo "[!] Vhosts Directory already exists"
		fi
	done
	echo "[+] Starting Nginx"
	systemctl start nginx
}
echo "[-] Starting Network Routine"
network
echo "[-] Starting Fake AP Routine"
hostapd
echo "[-] Starting Security Routine"
security
echo "[-] Starting WebServer Routine"
webserver
