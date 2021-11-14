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

---

## AIDE ET TROUBLESHOOTING

---

**NOTES ----- NE PAS INCLURE**
```
---- BEFORE INSTALL ----

sudo dnf update 
sudo dnf install epel-release 
sudo dnf install screen
sudo setenforce 0

---- NETDATA ----

bash <(curl -Ss https://my-netdata.io/kickstart.sh)
sudo firewall-cmd --permanent --zone=public --add-port=19999/tcp
sudo systemctl is-enabled netdata
# $? = 1 (false)
sudo systemctl is-active netdata
# $? = 3 (false)
sudo firewall-cmd --reload
# acces a netdata : [ip-machine]

---- INSTALL DE CRAFTY ----

git clone https://gitlab.com/crafty-controller/crafty-installer-linux.git && cd crafty-installer-linux && sudo ./install_crafty.sh

[DOCU :]
Install centos_8.sh requirements? - ['y', 'n']: y
Install Crafty to this directory? /var/opt/minecraft/crafty - ['y', 'n']: y
Which branch of Crafty would you like to run? - ['master', 'dev']: master
Would you like to make a service file for Crafty? - ['y', 'n']: y

sudo firewall-cmd --permanent --zone=public --add-port=8000/tcp
sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp
sudo firewall-cmd --permanent --zone=public --add-port=25565/udp
sudo firewall-cmd --reload

[DOCU :]
Chemin a optimal pour le backup : /minecraft/servers
IF UNABLE TO ACCESS TO /servers/...
chown -R crafty:crafty /var/opt/minecraft/servers


---- FIX EN CAS DE BUG SUR ARGON2 : ----

sudo chown -R crafty:crafty /var/opt/minecraft
sudo chmod -R 2775 /var/opt/minecraft

pip install --upgrade pip
(or pip3)

sudo su crafty
cd /var/opt/minecraft/crafty
source venv/bin/activate
cd crafty-web
pip install -r requirements.txt
(or pip3)


---- USE CRAFTY ON LINUX WINDOWING SERVICE (opti) :
screen -S crafty
cd /var/opt/minecraft/crafty/crafty-web
sudo su crafty -
./run_crafty.sh

DETACH : CTRL+A+D
REATTACH : screen -R crafty
```