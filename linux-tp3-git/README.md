 # DOCUMENTATION - Installation du serveur minecraft 

- [DOCUMENTATION - Installation du serveur minecraft](#documentation---installation-du-serveur-minecraft)
  - [CONFIGURATION MINIMALE REQUISE - Avant l'installation.](#configuration-minimale-requise---avant-linstallation)
  - [INSTALLATION - Script d'installation](#installation---script-dinstallation)
    - [**Aide à l'installation de crafty :**](#aide-à-linstallation-de-crafty-)
  - [INSTALLATION - Installation manuelle](#installation---installation-manuelle)
    - [**Configuration de la machine et installation des paquets :**](#configuration-de-la-machine-et-installation-des-paquets-)
    - [**Installation de NetData :**](#installation-de-netdata-)
    - [**Installation de crafty :**](#installation-de-crafty-)
  - [INSTALLATION - Backup et timer](#installation---backup-et-timer)
  - [AIDE ET TROUBLESHOOTING](#aide-et-troubleshooting)
    - [Crafty -- Manque d'un paquet pip (souvent argon2) :](#crafty----manque-dun-paquet-pip-souvent-argon2-)
    - [Crafty -- Crafty n'arrive pas à accéder à `/var/opt/minecraft/servers/server_x` :](#crafty----crafty-narrive-pas-à-accéder-à-varoptminecraftserversserver_x-)
    - [Service backup -- Pas la permission d'accèder à `/srv/backups` :](#service-backup----pas-la-permission-daccèder-à-srvbackups-)
    - [Service backup -- SELinux bloque l'execution de backup.sh :](#service-backup----selinux-bloque-lexecution-de-backupsh-)
  - [CREDITS](#credits)

---

## CONFIGURATION MINIMALE REQUISE - Avant l'installation.

Système D'Exploitation : Centos 8  
Processeur : 1.5GHz -- 2 coeurs (Possible à 1 coeur mais cela risque de lag)  
RAM = 2Go  
Stockage = 30Go (selon le nombre de serveurs)  
Réseau = Connexion internet (+ une ip dans le réseau local)  

Même si le script d'installation le fait en premier lieu, j'estime que votre machine est à jour  
Pour faire une MàJ faites : `sudo dnf update`

Il vous faut un minimum de connaissance en Linux pour installer cette solution, notamment avec VIM et la configuration de linux.

Je vous conseille de changer le nom de votre machine pour mieux vous repérer :  

```
$ sudo vim /etc/hostname
mc-server
```

> Je conseille mc-server mais vous pouvez choisir ce que vous voulez.
  
---

## INSTALLATION - Script d'installation

Vous pouvez installer les programmes nécessaires à ce projet avec ce script :

- [[ Script d'installation général ]](./scripts/installer.sh)  

Ou en faisant `wget https://raw.githubusercontent.com/valentin-dlack/tp-leo/master/linux-tp3-git/scripts/installer.sh`  

Si vous souhaitez installer un système de backup pour vos mondes et un timer pour backup régulièrement, allez à la section [INSTALLATION - Backup et timer](#installation---backup-et-timer).

### **Aide à l'installation de crafty :**

Lors de l'installation de crafty, il faut confirmer certaines informations, voici un petit guide pour savoir quoi mettre :

```
Install centos_8.sh requirements? - ['y', 'n']: y
Install Crafty to this directory? /var/opt/minecraft/crafty - ['y', 'n']: y
Which branch of Crafty would you like to run? - ['master', 'dev']: master
Would you like to make a service file for Crafty? - ['y', 'n']: y
```

Si vous rencontrez d'autres problèmes, réferrez vous à la section [AIDE ET TROUBLESHOOTING](#aide-et-troubleshooting)

---

## INSTALLATION - Installation manuelle  

Pour l'installation manuelle il suffit de suivre cette explication :  

### **Configuration de la machine et installation des paquets :**

On commence par passer selinux en mode permissif.  
`sudo setenforce 0`   
Ensuite nous allons installer les paquets necessaires à l'installation, mais d'abord, il faut mettre à jour.  
`sudo dnf update`  
Puis dans l'ordre :  
`sudo dnf install epel-release`  
`sudo dnf install screen`  

### **Installation de NetData :**

Netdata fourni un script d'installation rapide mais il faut modifier certaines configuration du par-feu et faire des vérification :  

- Installation avec le script :  
Tapez cette commande et suivez les instructions :  
`bash <(curl -Ss https://my-netdata.io/kickstart.sh)`

- Ajout du port `19999` au par-feu :  
  `sudo firewall-cmd --permanent --zone=public --add-port=19999/tcp`  
  `sudo firewall-cmd --reload`

- Vérification du service de netdata :  
  `sudo systemctl is-enabled netdata` (réponse attendue) -> `enabled`  
  `sudo systemctl is-active netdata` (réponse attendue) -> `active`

L'installation de Netdata est maintenant terminée, vous pouvez y accéder sur `http://[ip-machine]:19999`

### **Installation de crafty :**  

Crafty fourni aussi un script d'installation rapide, éxecutez cette commande :  

`git clone https://gitlab.com/crafty-controller/crafty-installer-linux.git && cd crafty-installer-linux && sudo ./install_crafty.sh`

Pour vous guider dans les informations à donner voici un guide :  

``` 
Install centos_8.sh requirements? - ['y', 'n']: y
Install Crafty to this directory? /var/opt/minecraft/crafty - ['y', 'n']: y
Which branch of Crafty would you like to run? - ['master', 'dev']: master
Would you like to make a service file for Crafty? - ['y', 'n']: y
```

Sur le reste il suffira de suivre les instructions.

- Configuration du par-feu pour Crafty et Minecraft Server :  
  `sudo firewall-cmd --permanent --zone=public --add-port=8000/tcp`  
  `sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp`  
  `sudo firewall-cmd --permanent --zone=public --add-port=25565/udp`  
  `sudo firewall-cmd --reload`  

Le port 8000 est utilisé pour le WebGUI de Crafty et le port 25565 est utilisé pour le serveur minecraft.

Il faudra ensuite créer un dossier pour placer vos fichiers de serveurs :  

**Ceci est l'architecture recommandée, sans elle le backup ne fonctionnera pas sans modification !**

Les dossiers/fichiers serait réparti comme ceci (dans `/var/opt/minecraft/`) :


*`/var/opt/minecraft/`***`servers/serv_1...`**
```
servers 
│
└───server_1
│   │   eula.txt
│   │   server.jar
│   |   ect...
│   
└───server_2
|   |   server.jar
|   |   ect...
|   
└───server...
```

**/!\ SI CETTE ARCHITECHTURE N'EST PAS RESPECTEE LE BACKUP NE SERA PAS FONCTIONNEL /!\\**

L'installation manuelle est terminée, si vous avez des problèmes allez voir la section [AIDE ET TROUBLESHOOTING](#aide-et-troubleshooting).  

Si vous souhaitez installer une solution de backup pour vos mondes et un timer pour sauvegarder périodiquement allez voir la section [INSTALLATION - Backup et timer](#installation---backup-et-timer).  

---

## INSTALLATION - Backup et timer

- **INSTALLATION DE LA SOLUTION DE BACKUP**  

    Vous pouvez installer la solution de backup avec ce script :

    - [[ Script d'installation backup ]](./scripts/backup-installer.sh)  

    Ou en faisant `wget https://raw.githubusercontent.com/valentin-dlack/tp-leo/master/linux-tp3-git/scripts/backup-installer.sh`

    Pour effectuer un backup, il suffit de faire la commande `sudo systemctl start backup`  
    *Si le service ne démarre pas réferrez vous à la section [AIDE ET TROUBLESHOOTING](#aide-et-troubleshooting).*  

- **SETUP DU TIMER**

    Pour créer un timer, il suffit de créer un fichier en `.timer` dans le répertoire `/etc/systemd/system/`

    Ici notre fichier sera du même nom que notre service : `backup.timer`

    `/etc/systemd/system/backup.timer`
    ```
    [Unit]
    Description=Periodically run the world backup service
    Requires=backup.service

    [Timer]
    Unit=backup.service
    OnCalendar=*-*-* 1:00:00

    [Install]
    WantedBy=timers.target
    ```

    `OnCalendar` permet de régler quand et à quel période nos backups seront fait, voici comment l'utiliser et le comprendre :  

    ```
    - daily = à minuit chaque jour
    - weekly = tous les lundis à minuit
    - DayOfWeek Year-Month-Day Hour:Minute:Second Au format attendu

    Exemples :
    - OnCalendar=*-*-* 1:00:00 : Tous les jours à 1h du matin
    - OnCalendar=Sun *-*-* 12:00:00 : Tous les dimanches à midi
    - OnCalendar=*-*-1 00:20:00 : Tous les premiers du mois à 00h20
    - OnCalendar=Mon *-*-1..7 6:00:00 ; Du 1 au 7 du mois, qui soit un lundi, à 6h (traduisez le premier lundi du mois à 6h)

    Côté syntaxe :
    - * : Toutes les occurrences
    - 1 : Occurrence 1
    - 1..7 : Occurrences de 1 à 7
    - 0,12 : Occurrences 0 et 12
    ```

    > Et voilà ! notre timer est créé, il suffit maintenant de le démarrer et de l'activer pour qu'il démarre au boot, on fait ça avec ces deux commandes :  

    Activation : `sudo systemctl start backup.timer`  
    Démarrage au boot : `sudo systemctl enable backup.timer`

    On fini par faire `sudo systemctl list-timers` pour voir si notre timer est bien présent.

> L'installation du backup et du timer est maintenant fini !

---

## AIDE ET TROUBLESHOOTING

Ici seront notés les solutions que j'ai pu trouver à certains bugs présents dans l'installation dans certaines situations et sur certaines machines. Si vous ne trouvez pas la solution à votre problème contactez moi où ouvrez une issue.

### Crafty -- Manque d'un paquet pip (souvent argon2) :  

Quand vous essayez de démarrer `run-crafty.sh` une erreur indiquant qu'il manque un module apparait :  

**FIX :**  

SUR VOTRE USER NORMAL :  

```
sudo chown -R crafty:crafty /var/opt/minecraft
sudo chmod -R 2775 /var/opt/minecraft
```

Ensuite si vous avez pip :  

`pip install --upgrade pip`

Si vous avez pip3 : 

`pip3 install --upgrade pip`

**!!! AVANT DE FAIRE CA, PASSEZ SUR L'UTILISATEUR CRAFTY !!! :** 

`sudo su crafty`

Ensuite faites ces commandes à la suite (dans l'ordre) :

```
cd /var/opt/minecraft/crafty
source venv/bin/activate
cd crafty-web
pip install -r requirements.txt
```

Réessayez de démarrer `run-crafty.sh` et normalement il devrait marcher.

### Crafty -- Crafty n'arrive pas à accéder à `/var/opt/minecraft/servers/server_x` :

C'est un problème de permission qui faut régler en faisant ces commandes :  

```
sudo chown -R crafty:crafty /var/opt/minecraft/servers
```

Normalement, après ça, le problème est réglé.

### Service backup -- Pas la permission d'accèder à `/srv/backups` :

Il suffit de régler ça avec un chmod 

`sudo chmod ug+rwx /srv/backups`   
`sudo chmod o+r /srv/backups`

### Service backup -- SELinux bloque l'execution de backup.sh :

J'ai eu ce problème une fois, il fallait juste refaire la commande :  
`sudo setenforce 0`

---

## CREDITS 

Merci à Crafty (https://craftycontrol.com/) d'avoir mis une solution très complète et très propre de gestion de serveur minecraft.  
Merci au serveur discord du support pour avoir été très réactif.  
Et enfin merci à Léo de m'avoir appris à faire tout ça c'est quand même assez classe.
