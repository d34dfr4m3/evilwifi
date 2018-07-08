#!/bin/bash
function hostapd(){
	echo "[+] Setup HostAPD"
	echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >/etc/default/hostapd
	cp conf/hostapd.conf /etc/hostapd/hostapd.conf
	/etc/init.d/hostapd start
	
}
hostapd
