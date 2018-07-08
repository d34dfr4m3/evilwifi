#!/bin/bash
function hostapd(){
	echo "[+] Setup HostAPD"
	echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >/etc/default/hostapd
	cp conf/hostapd.conf /etc/hostapd/hostapd.conf
	#/etc/init.d/hostapd start
	
}
function network(){
	echo "[+] Shutdown wlan1"
	ifconfig wlan1 down
	echo "[+] Setup wlan1 at /etc/network/interfaces"
	cat conf/wlan1 >> /etc/network/interfaces
	echo "[+] Bring up wlan1"
	ifup wlan1

	echo "[+] Configuring Dnsmasq"
	cp conf/dnsmasq.conf /etc/dnsmasq.conf
	#/etc/init.d/dnsmasq start
	echo "[+] Enabling routing"
	sysctl net.ipv4.ip_forward=1
}
hostapd
network
