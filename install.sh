#!/bin/bash
send="message.sh"
function check_sys(){
	OSBASED=$(grep ID_LIKE /etc/*release | cut -d '=' -f 2)
}
function basic(){
	case $1 in
		debian)
			. message.sh status "Installing software using apt"
			apt update && apt install nginx dnsmasq mdk3 hostapd php php-fpm git ruby2.5* -y
			. message.sh status "Downloading beef using apt"
			git clone https://github.com/beefproject/beef.git /opt/beef
		;;
	esac
}
function check_install(){
	. message.sh check "Checking Nginx"
	if [ -f /etc/init.d/nginx ];then
		. message.sh status "Nginx OK"
	else
		. message.sh error "Nginx is missing"
	fi
	. message.sh check "Checking Dnsmasq"
	if [ -f /etc/init.d/dnsmasq ];then
		. message.sh status "Dnsmasq OK"
	else
		. message.sh error "Dnsmasq is missing"
	fi
	. message.sh check "Checking hosaptd"
	if [ -f /etc/init.d/hostapd ];then
		. message.sh status "hosapd OK"
	else
		. message.sh error "Dnsmasq is missing"
	fi
	. message.sh check "Checking MDK3"
	if [ -f /usr/sbin/mdk3 ];then
		. message.sh status "MDK3 OK"
	else
		. message.sh error "MDK3 is missing"
	fi
	. message.sh check "Checking PHP"
	if [ -f /usr/bin/php ];then
		. message.sh status "PHP OK, VERSION: $(php -v | head -n1 | cut -d '(' -f1)"

	else
		. message.sh error "PHP is missing"
	fi
}
if [ $(id -u) -ne 0 ];then
	. message error "God mode required, i'm leaving"
	exit 1
else
	check_sys
	if [ ! -f message.sh ];then
		. message.sh error "Message file is missing, aborting now!"
		exit 1
	else
	case $OSBASED in
		debian|DEBIAN)
			basic $OSBASED
			;;
		
		*) 	. message.sh error "Sorry, your system isn't compatible yet, please report" 
			exit 1
			;;
	esac 
	check_install
	. message.sh status "Good to go, now run ./setup.sh"
fi
fi
