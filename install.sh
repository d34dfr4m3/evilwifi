#!/bin/bash
# echo 	+ Means Action
# 	- Means checks
# 	! Means Errors
# 	* Status Update
function check_sys(){
	OSBASED=$(grep ID_LIKE /etc/*release | cut -d '=' -f 2)
}
function basic(){
	case $1 in
		debian)
			echo "[+] Installing software using apt"
			apt update && apt install nginx isc-dhcp-server mdk3 bind9 hostapd -y
		;;
	esac
}
function check_install(){
	echo "[-] Checking if Nginx is OK"	
	if [ -f /etc/init.d/nginx ];then
		echo "	[*] Nginx OK"
	else
		echo "	[!] Nginx is missing"
	fi
	echo "[-] Checking if DHCP is OK"	
	if [ -f /etc/init.d/isc-dhcp-server ];then
		echo "	[*] isc-dhcp-server OK"
	else
		echo "	[!] isc-dhcp-server is missing"
	fi
	echo "[-] Checking if BIND9 is OK"	
	if [ -f /etc/init.d/bind9 ];then
		echo "	[*] bind9 OK"
	else
		echo "	[!] Bind9 is missing"
	fi
	echo "[-] Checking if hostapd is OK"	
	if [ -f /etc/init.d/hostapd ];then
		echo "	[*] hostapd OK"
	else
		echo "	[!] hostapd is missing"
	fi
}
check_sys
case $OSBASED in
	debian|DEBIAN)
		basic $OSBASED
		;;
	*) echo "[!] Sorry, your system isn't compatible yet, please report" 
		;;
esac 
check_install
