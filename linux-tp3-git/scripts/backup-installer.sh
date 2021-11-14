#!/bin/bash
#Programme d'installation d'un système de backup pour minecraft project + service
# Lack_off1 -- 14/11/2021
sudo -v
sudo_test="$?"
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
    echo "    https://github.com/valentin-dlack/tp-leo/tree/master/linux-tp3-git"
elif [ "${fail}" -eq 0 ];then
    if [[ $EUID -ne 0 ]]; then
        echo "Note: Vous n'êtes pas en root, Ré-executez ce script en sudo."
        sudo "$0"
    else
        mkdir -p /srv/backups

        # set backup script
        wget -P /srv/ https://raw.githubusercontent.com/valentin-dlack/tp-leo/master/linux-tp3-git/scripts/backup.sh

        #set perms
        chmod 774 /srv/backup.sh
        chmod ug+rwx /srv/backups
        chmod o+rx /srv/backups

        # setup service file
        cat << EOF > /etc/systemd/system/backup.service
        [Unit]
        Description=Backup Service for minecraft server

        [Service]
        ExecStart=/srv/backup.sh /srv/backups /var/opt/minecraft/servers
        Type=oneshot
        RemainAfterExit=no

        [Install]
        WantedBy=multi-user.target
EOF

        echo "Le système de backup a été installé, vous pouvez le tester avec 'sudo systemctl start backup'"
        echo "  Vous voulez des backups réguliers ? Un tutoriel pour créer un timer est disponible dans la documentation"
    fi
else
   echo "ERREUR FATALE - Il y a un problème avec le script, veuillez contacter le developpeur SVP"
fi

