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
			apt update && apt install nginx dnsmasq mdk3 hostapd -y
		;;
	esac
}
function check_install(){
	echo "[-] Checking Nginx "	
	if [ -f /etc/init.d/nginx ];then
		echo "	[*] Nginx OK"
	else
		echo "	[!] Nginx is missing"
	fi
	echo "[-] Checking Dnsmasq "	
	if [ -f /etc/init.d/dnsmasq ];then
		echo "	[*] dnsmasq OK"
	else
		echo "	[!] dnsmasq is missing"
	fi
	echo "[-] Checking hostapd"	
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

echo "[+] Good to go, now run ./setup.sh"
