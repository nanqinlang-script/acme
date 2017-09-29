#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: acme
# Version: 1.3
# Author: nanqinlang
# Blog:   https://www.nanqinlang.com
# Github: https://github.com/nanqinlang
#======================================${Font_suffix}"

#check system
check_system(){
	cat /etc/issue | grep -q -E -i "debian" && release="debian" 
	cat /etc/issue | grep -q -E -i "ubuntu" && release="ubuntu"
	if [[ "${release}" = "debian" || "${release}" != "ubuntu" ]]; then
	echo -e "${Info} system is ${release}"
	else echo -e "${Error} not support!" && exit 1
	fi
}

#check root
check_root(){
	if [[ "`id -u`" = "0" ]]; then
	echo -e "${Info} user is root"
	else echo -e "${Error} must be root user" && exit 1
	fi
}

#determine workplace directory
directory(){
	[[ ! -d /home/acme ]] && mkdir -p /home/acme
	cd /home/acme
}

	check_system
	check_root
	directory
	apt-get install zip -y && wget https://raw.githubusercontent.com/nanqinlang/acme/master/acme.zip && unzip acme.zip && chmod -R 7777 /home/acme && rm acme.zip

	echo -e "${Info} input domain(defaultly cancel):"
	stty erase '^H' && read domain
	[[ -z "${domain}" ]] && echo -e "${Error} not input domain, exiting..." && exit 1

	echo -e "${Info} select required type:\n1.rsa\n2.ecc"
	stty erase '^H' && read -p "(defaultly cancel):" type
	if [[ -z "${type}" ]]; then
		echo -e "${Error} not input type, exiting..." && exit 1
	elif [[ "${type}" = "1" ]]; then
		./acme.sh --issue --dns -d ${domain}
	elif [[ "${type}" = "2" ]]; then
		./acme.sh --issue --dns -d ${domain} -k ec-256
	else echo -e "${Error} invalid input, exiting" && exit 1
	fi

	echo -e "${Info} then you should finish domain txt record"
	stty erase '^H' && read -p "then press 'enter' to continue"
	if [[ "${type}" = "rsa" ]]; then
		 ./acme.sh --renew -d ${domain}
	else ./acme.sh --renew -d ${domain} --ecc
	fi

	mv -f /root/.acme.sh /home/acme/crt
	if [[ -d /home/acme/crt ]]; then
		echo -e "${Info} certification files are in /home/acme/crt" && exit 0
		else echo -e "${Error} product certification files failed, please check!" && exit 1
	fi
