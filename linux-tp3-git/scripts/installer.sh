#!/bin/bash
# Auto installation script for minecraft project
# Lack_off -- 13/11/2021
sudo -v
sudo_test="$?"
ip_addr=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
if [ "${sudo_test}" -eq 127 ];then
    echo "ERREUR: vous devez etre en sudo pour l'installation"
    fail=1
elif [ "${sudo_test}" -eq 1 ];then
    echo "Malheureusement, votre système a l'air de limiter la commande sudo pour votre utilisateur "
    fail=1
elif [ "${sudo_test}" -eq 0 ];then
    fail=0
else
    echo "ERREUR FATALE - Il y a un gros problème (sudo_test is ${sudo_test}). SVP Envoyez l'erreur au developpeur"
fi

if [ "${fail}" -eq 1 ];then
    echo "Veuillez vous renseigner sur la documentation :"
    echo "    [doc link]"
elif [ "${fail}" -eq 0 ];then
    if [[ $EUID -ne 0 ]]; then
        echo "Note: Vous n'êtes pas en root, Ré-executez ce script en sudo."
        sudo "$0"
    else
	#Installation part ----------------
	#dnf update & package install
	dnf update
	dnf install epel-release
	dnf install screen

	#selinux config
	setenforce 0

	#installation de netdata
	bash <(curl -Ss https://my-netdata.io/kickstart.sh)
	firewall-cmd --permanent --zone=public --add-port=19999/tcp
	firewall-cmd --reload
	
	#Check si netdata est enable et/ou démarré
	systemctl is-enabled netdata
	if [ $? -eq 1 ];then
		systemctl enable netdata
	fi

	systemctl is-active netdata
	if [ $? -eq 3 ];then
		systemctl start netdata
	fi
	echo "Le dashboard NetData http://$ip_addr:19999 Si ce lien ne marche pas essayez http://[ip-machine]:19999"

	#installation de crafty
	git clone https://gitlab.com/crafty-controller/crafty-installer-linux.git && cd crafty-installer-linux && sudo ./install_crafty.sh

	firewall-cmd --permanent --zone=public --add-port=8000/tcp
	firewall-cmd --permanent --zone=public --add-port=25565/tcp
	firewall-cmd --permanent --zone=public --add-port=25565/udp
	firewall-cmd --reload

	#End of install part
    fi
else
   echo "ERREUR FATALE - Il y a un problème avec le script, veuillez contacter le developpeur SVP"
fi
