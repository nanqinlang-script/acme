#!/bin/bash
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: acme
# Version: 1.5
# Author: nanqinlang
# Blog:   https://www.nanqinlang.com
# Github: https://github.com/nanqinlang
#======================================${Font_suffix}"

check_root(){
	[[ "`id -u`" != "0" ]] && echo -e "${Error} must be root user" && exit 1
}

directory(){
	[[ ! -d /home/acme ]] && mkdir -p /home/acme
	cd /home/acme
}

	check_root
	directory
	[[ ! -f make.sh ]] && wget https://raw.githubusercontent.com/nanqinlang-script/acme/master/acme.tar && tar -xf acme.tar && chmod +x make.sh && rm acme.tar
	[[ ! -f make.sh ]] && echo -e "${Error} file not exist, please check!" && exit 1

	echo -e "${Info} input your domain:"
	read -p "(defaultly cancel):" domain
	[[ -z "${domain}" ]] && echo -e "${Error} not input domain, exiting..." && exit 1

	echo -e "${Info} select required type:\n1.rsa\n2.ecc"
	read -p "(defaultly choose rsa):" type
	if [[ -z "${type}" ]]; then
		./make.sh --issue --dns -d ${domain}
	elif [[ "${type}" = "1" ]]; then
		./make.sh --issue --dns -d ${domain}
	elif [[ "${type}" = "2" ]]; then
		./make.sh --issue --dns -d ${domain} --keylength ec-256
	else
		echo -e "${Error} invalid input, exiting" && exit 1
	fi

	echo -e "${Info} now you should perform domain TXT record authorization"
	read -p "then press 'enter' to continue"
	if [[ "${type}" = "1" ]]; then
		 ./make.sh --renew -d ${domain} && mv -f /root/.acme.sh/${domain} /home/${domain}
	else ./make.sh --renew -d ${domain} --ecc && mv -f /root/.acme.sh/${domain}_ecc /home/${domain}_ecc
	fi

	rm -rf /root/.acme.sh /home/acme

	if [[ "${type}" = "1" ]]; then
		if [[ -d /home/${domain} ]]; then
			 echo -e "${Info} SSL certificate files are in /home/${domain} "
		else echo -e "${Error} failed, please check !"
		fi
	else
		if [[ -d /home/${domain}_ecc ]]; then
			 echo -e "${Info} SSL certificate files are in /home/${domain}_ecc "
		else echo -e "${Error} failed, please check !"
		fi
	fi
