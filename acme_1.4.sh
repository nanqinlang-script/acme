#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: acme
# Version: 1.4
# Author: nanqinlang
# Blog:   https://www.nanqinlang.com
# Github: https://github.com/nanqinlang
#======================================${Font_suffix}"

#check root
check_root(){
	[[ "`id -u`" != "0" ]] && echo -e "${Error} must be root user" && exit 1
}

#determine workplace directory
directory(){
	[[ ! -d /home/acme ]] && mkdir -p /home/acme
	cd /home/acme
}

	check_root
	directory
	[[ ! -f make.sh ]] && wget https://raw.githubusercontent.com/nanqinlang/acme/master/acme.tar && tar -xf acme.tar && chmod 7777 make.sh && rm acme.tar
	[[ ! -f make.sh ]] && echo -e "${Error} file not exist, please check!" && exit 1

	echo -e "${Info} input domain:"
	read -p "(defaultly cancel):" domain
	[[ -z "${domain}" ]] && echo -e "${Error} not input domain, exiting..." && exit 1

	echo -e "${Info} select required type:\n1.rsa\n2.ecc"
	read -p "(defaultly cancel):" type
	if [[ -z "${type}" ]]; then
		echo -e "${Error} not input type, exiting..." && exit 1
	elif [[ "${type}" = "1" ]]; then
		./make.sh --issue --dns -d ${domain}
	elif [[ "${type}" = "2" ]]; then
		./make.sh --issue --dns -d ${domain} --keylength ec-384
	else
		echo -e "${Error} invalid input, exiting" && exit 1
	fi

	echo -e "${Info} now you should perform domain txt record authorization"
	read -p "then press 'enter' to continue"
	if [[ "${type}" = "rsa" ]]; then
		 ./make.sh --renew -d ${domain} && mv -f /root/.acme.sh/${domain} /home/acme/crt/${domain}
	else ./make.sh --renew -d ${domain} --ecc && mv -f /root/.acme.sh/${domain}_ecc /home/acme/crt/${domain}
	fi

	rm -rf /root/.acme.sh && rm make.sh
	if [[ -d /home/acme/crt/${domain} ]]; then
		echo -e "${Info} certification files are in /home/acme/crt/${domain} " && exit 0
		else echo -e "${Error} product certification files failed, please check!" && exit 1
	fi
