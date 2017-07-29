#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Yellow_font="\033[33m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
reboot="${Yellow_font}reboot${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: acme
# Version: 1.0
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

preparatory(){
    check_system
	check_root
	directory
	[[ ! -e acme.sh ]] && apt-get install zip -y && wget https://raw.githubusercontent.com/nanqinlang/acme/master/acme.zip && unzip acme.zip && chmod -R 7777 /home/acme
}

#crt(){
    preparatory
	echo -e "${Info} input domain(defaultly cancel):"
	stty erase '^H' && read domain
	[[ -z "${domain}" ]] && echo -e "${Info} exiting" && exit 1
	echo -e "${Info} input certification type:"
	stty erase '^H' && read -p "(rsa or ecc):" type
	if [[ -z "${type}" ]]; then
	    echo -e "${Info} not input type, exiting" && exit 1
	elif [[ "${type}" = "rsa" ]]; then
	    ./acme.sh --issue --dns -d ${domain} -k
	elif [[ "${type}" = "ecc" ]]; then
	    ./acme.sh --issue --dns -d ${domain} -k ec-256
	else echo -e "${Error} invalid input, exiting" && exit 1
	fi
	echo -e "${Info} after finished domain certification"
	stty erase '^H' && read -p "press enter to continue"
	if [[ "${type}" = "rsa" ]]; then
         ./acme.sh --renew -d ${domain}
	else ./acme.sh --renew -d ${domain} --ecc
	fi
	mv /root/.acme.sh /home/acme/crt
	if [[ -d /home/acme/crt ]]; then
	    echo -e "${Info} certification files are in /home/acme/crt" && exit 0
	    else echo -e "${Error} product certification files failed, please check!" && exit 1
	fi
#}