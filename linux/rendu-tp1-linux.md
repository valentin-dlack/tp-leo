# TP - 1  Linux  

- [TP - 1  Linux](#tp---1--linux)
  - [A - Préparation de la machine](#a---préparation-de-la-machine)
    - [Test d'accès internet :](#test-daccès-internet-)
    - [Accès au réseau local :](#accès-au-réseau-local-)
    - [Nom des machines :](#nom-des-machines-)
    - [Vérification de la configuation du DNS :](#vérification-de-la-configuation-du-dns-)
    - [Configuation et test des nom d'hotes :](#configuation-et-test-des-nom-dhotes-)
    - [Vérification de la configuation du firewall :](#vérification-de-la-configuation-du-firewall-)
  - [B -- Utilisateurs](#b----utilisateurs)
    - [Création du groupe admin :](#création-du-groupe-admin-)
    - [SSH :](#ssh-)
  - [C -- Partitionnement :](#c----partitionnement-)
  - [D -- Gestion et Création de services :](#d----gestion-et-création-de-services-)
    - [Actions sur un service existant :](#actions-sur-un-service-existant-)
    - [Création d'un service à part entière :](#création-dun-service-à-part-entière-)
    - [Modification du service :](#modification-du-service-)

## A - Préparation de la machine  

### Test d'accès internet :  

node1 : 

```
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:c0:1e:b5 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 84218sec preferred_lft 84218sec
    inet6 fe80::a00:27ff:fec0:1eb5/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

node2 : 
```
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:13:58:11 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 84692sec preferred_lft 84692sec
    inet6 fe80::a00:27ff:fe13:5811/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```
Le ping 8.8.8.8 fonctionne sur les deux machines :  
Pour node1 :
```
[lack@node1 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=18.7 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=33.6 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=114 time=17.4 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=114 time=22.1 ms
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3007ms
rtt min/avg/max/mdev = 17.400/22.937/33.571/6.375 ms
[lack@node1 ~]$ ping google.com
PING google.com (216.58.204.142) 56(84) bytes of data.
64 bytes from par21s05-in-f14.1e100.net (216.58.204.142): icmp_seq=1 ttl=114 time=18.10 ms
64 bytes from par21s05-in-f14.1e100.net (216.58.204.142): icmp_seq=2 ttl=114 time=21.1 ms
64 bytes from par21s05-in-f14.1e100.net (216.58.204.142): icmp_seq=4 ttl=114 time=25.4 ms
64 bytes from par21s05-in-f14.1e100.net (216.58.204.142): icmp_seq=5 ttl=114 time=23.7 ms
```
Pour node2 :
```
[lack@node2 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=21.10 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=33.6 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=114 time=18.5 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=114 time=18.2 ms
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 18.237/23.062/33.553/6.232 ms
[lack@node2 ~]$ ping google.com
PING google.com (216.58.204.142) 56(84) bytes of data.
64 bytes from par21s05-in-f142.1e100.net (216.58.204.142): icmp_seq=1 ttl=114 time=18.9 ms
64 bytes from par21s05-in-f142.1e100.net (216.58.204.142): icmp_seq=2 ttl=114 time=21.1 ms
64 bytes from par21s05-in-f142.1e100.net (216.58.204.142): icmp_seq=3 ttl=114 time=18.3 ms
64 bytes from par21s05-in-f142.1e100.net (216.58.204.142): icmp_seq=4 ttl=114 time=18.1 ms
--- google.com ping statistics ---
```


### Accès au réseau local :
node1 : (ping et config)
```
---- ping node2 :
[lack@node1 ~]$ ping 10.101.1.12
PING 10.10.1.12 (10.10.1.12) 56(84) bytes of data.
64 bytes from 10.101.1.12: icmp_seq=1 ttl=64 time=0.346 ms
64 bytes from 10.101.1.12: icmp_seq=2 ttl=64 time=0.316 ms
64 bytes from 10.101.1.12: icmp_seq=3 ttl=64 time=0.320 ms
64 bytes from 10.101.1.12: icmp_seq=4 ttl=64 time=0.385 ms

---- config :
BOOTPROTO=static
IPADDR=10.101.1.11
NETMASK=255.255.255.0
DNS1=1.1.1.1
NAME=enp0s8
UUID=0ce21882-90dd-4faf-a17e-871e5ec3e5cf
DEVICE=enp0s8
ONBOOT=yes
```

node2 : (ping vers node1 et config)
```
---- ping node2 :
[lack@node2 ~]$ ping 10.101.1.11
PING 10.101.1.11 (10.101.1.11) 56(84) bytes of data.
64 bytes from 10.101.1.11: icmp_seq=1 ttl=64 time=0.554 ms
64 bytes from 10.101.1.11: icmp_seq=2 ttl=64 time=0.358 ms
64 bytes from 10.101.1.11: icmp_seq=3 ttl=64 time=0.287 ms
64 bytes from 10.101.1.11: icmp_seq=4 ttl=64 time=0.402 ms
--- 10.101.1.11 ping statistics ---

---- config :
BOOTPROTO=static
IPADDR=10.101.1.12
NETMASK=255.255.255.0
DNS1=1.1.1.1
NAME=enp0s8
UUID=0ce21882-90dd-4faf-a17e-871e5ec3e5cf
DEVICE=enp0s8
ONBOOT=yes
```

---

### Nom des machines :  

Node1 :
```
[lack@node1 ~]$ cat /etc/hostname
node1.tp1.b2
```

Node2 :  
```
[lack@node2 ~]$ cat /etc/hostname
node2.tp1.b2
```

---

### Vérification de la configuation du DNS :  

Nous allons faire un dig vers `ynov.com` pour vérifier que le dns fonctionne correctement :  

Pour `node1` :  

```
[lack@node1 ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51679
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               849     IN      A      > 92.243.16.143 <

;; Query time: 9 msec
;; SERVER: > 10.33.10.2#53(10.33.10.2) <
[...]
```
> Les Informations importantes sont mises en évidence tel que `> info <`  

Pour `node2` :  

```
[lack@node2 ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54141
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               655     IN      A      > 92.243.16.143 <

;; Query time: 3 msec
;; SERVER: > 10.33.10.2#53(10.33.10.2) <
[...]
```

---  

### Configuation et test des nom d'hotes :  

Il faut que nos machines puissent se ping directement avec leurs noms d'hôtes. Pour ça on va utiliser `/etc/hosts`  

- Pour node1 :
   - Config de /etc/hosts
      ```
      [lack@node1 ~]$ cat /etc/hosts
      127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
      ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
      10.101.1.12 node2.tp1.b2
      ```
   - Ping vers node2 (avec le nom)
      ```
      [lack@node1 ~]$ ping node2.tp1.b2
      PING node2.tp1.b2 (10.101.1.12) 56(84) bytes of data.
      64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=1 ttl=64 time=0.379 ms
      64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=2 ttl=64 time=0.312 ms
      64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=3 ttl=64 time=0.473 ms
      64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=4 ttl=64 time=0.367 ms
      ^C
      --- node2.tp1.b2 ping statistics ---
      4 packets transmitted, 4 received, 0% packet loss, time 3108ms
      ```

- Pour node2 :  
  - Config de /etc/hosts
      ```
      [lack@node2 ~]$ cat /etc/hosts
      127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
      ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
      10.101.1.11 node1.tp1.b2
      ```
   - Ping vers node1 (avec le nom)
      ```
      [lack@node2 ~]$ ping node1.tp1.b2
      PING node1.tp1.b2 (10.101.1.11) 56(84) bytes of data.
      64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=1 ttl=64 time=0.330 ms
      64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=2 ttl=64 time=0.320 ms
      64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=3 ttl=64 time=0.452 ms
      64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=4 ttl=64 time=0.374 ms
      [...]
      ```

---

### Vérification de la configuation du firewall :  

Il faut configurer sur le firewall pour n'accepter que les ports utiles (ici le port 22 du SSH) :  

- Pour node1 :  
```
[lack@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

- Pour node2 :  
```
[lack@node2 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

--- 

## B -- Utilisateurs

On crée des utilisateurs qui servirons à l'administration sur les deux machines (la procédure est la même) :  

Création de l'utilisateur :  
```
[lack@node1]$ useradd lackadmin
```

L'utilisateur a bien été ajouté et son répertoire est présent dans `/home/` :  

```
[lack@node1 ~]$ ls /home/
lack  lackadmin
```

### Création du groupe admin :  

Il faut créer un groupe admin pour y mettre notre nouvel utilisateur et ajouter ce groupe admin aux sudoers.  

**Création du groupe :**  

```
[lack@node1 ~]$ sudo groupadd admin
```

**Vérification de l'éxistence du groupe `admin`**  

```
[lack@node1 ~]$ cat /etc/group
root:x:0:
bin:x:1:
daemon:x:2:
[...]
slocate:x:21:
lack:x:1000:
lackadmin:x:1001:
admin:x:1002:
```

**Ajout du nouveau groupe au sudoers**  

On ne peut pas directement modifier le fichier des sudoers, on utilisera `visudo` :  

```
[lack@node1 ~]$ sudo visudo
```

Puis dans le fichier, on modifie ainsi :  
```bash
## Allows people in group wheel to run all commands
%wheel  ALL=(ALL)       ALL
%admin  ALL=(ALL)       ALL
```

**Ajout de l'utilisateur au groupe `admin`**  

```
[lack@node1 ~]$ sudo usermod -aG admin lackadmin
```

On vérifie que lackadmin a bien été ajouté avec `/etc/group` :  

```
[lack@node1 ~]$ grep lackadmin /etc/group
lackadmin:x:1001:
admin:x:1002:lackadmin
```

Le compte fait bien parti du groupe admin.

---

### SSH :

Après avoir généré une clé ssh depuis mon poste (avec ssh-keygen sur powershell), j'ajoute la clé dans le fichier `/home/lackadmin/.ssh/authorized_keys` : 

```
[lackadmin@node1 .ssh]$ cat authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRYsF5cYCweb3tgxAUkkM/wfXkY5JxUeecLAj4CH7SoDlqwAnQ+zznqt0MOanHn+xh1oOuF/zH0j+wk9OUuXq0oepTYG0xfV8RGKkms3Tfldm6U12lUVkaMqMODuosXeCgaqJJ0Cl/RBmxXLWfkJMvSFV7Al7nmlq5T52EtSJP9J4JhkmwIJ1R7mk0dziE/QIzuilI7F+K5YOyJ3EB24+n62uv1i742iTvRRRocwkT3GqggCsua4U2A+8zmHvM6lgvE/zj7McENw+m5YxyPoKEYtzrhYaNotwT1znZBi/Gk5Aiq6MxQ6fIZ0wMWa7IRigU6j8o2ssWiQ0w7CQkxOBB0YYlI8URiYpO5fcTJavXxnQj9u0KdXc1ZFtVcDHaLY62zLJPSN22cvXjEMgQPk5xqbezkqBbH+P6zakgn3H2WUYmxxQ2yJ9S9jCZ8DXtXeUk4Xz2ZPBbjkwnO7190oPX6C3If/WF83gXeJoE0s2usxjCnkjm9aNkMKkIK4wdvG8= lolva@DESKTOP-KHB2MRJ
```

Je redémarre l'agent ssh de windows par précaution  
`Restart-Service ssh-agent`

Puis pour finir, j'essai de me connecter en ssh sans mettre de mot de passe :  

```
PS C:\Users\lolva> ssh lackadmin@10.101.1.11
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Sun Sep 26 18:18:20 2021 from 10.101.1.1
[lackadmin@node1 ~]$
```

Le tour est joué !

---

## C -- Partitionnement :  

Nous allons utiliser lvm pour travailler sur le partitionnement linux.

> Créer 1 *volume group* avec deux disques de 3Go

Je créer des volumes physique :  

```
[lackadmin@node1 ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[lackadmin@node1 ~]$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
[lackadmin@node1 ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0
  /dev/sdb      lvm2 ---   3.00g 3.00g
  /dev/sdc      lvm2 ---   3.00g 3.00g
```

On créer ensuite le *volume group* en question :  

```
[lackadmin@node1 ~]$ sudo vgcreate ndata /dev/sdb
[sudo] password for lackadmin:
  Volume group "ndata" successfully created
[lackadmin@node1 ~]$ sudo vgs
  VG    #PV #LV #SN Attr   VSize  VFree
  ndata   1   0   0 wz--n- <3.00g <3.00g
  rl      1   2   0 wz--n- <7.00g     0
[lackadmin@node1 ~]$ sudo vgextend ndata /dev/sdc
  Volume group "ndata" successfully extended
[lackadmin@node1 ~]$ sudo vgs
  VG    #PV #LV #SN Attr   VSize  VFree
  ndata   2   0   0 wz--n-  5.99g 5.99g
  rl      1   2   0 wz--n- <7.00g    0
```

> Créer (à partir du VG) 3 logical volume de 1Go chacun :  

```
[lackadmin@node1 ~]$ sudo lvcreate -L 1G ndata -n data_un
  Logical volume "data_un" created.
[lackadmin@node1 ~]$ sudo lvcreate -L 1G ndata -n data_deux
  Logical volume "data_deux" created.
[lackadmin@node1 ~]$ sudo lvcreate -L 1G ndata -n data_trois
  Logical volume "data_trois" created.
```

Check si les trois volumes existent :  

```
[lackadmin@node1 ~]$ sudo lvs
  LV         VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  data_deux  ndata -wi-a-----   1.00g
  data_trois ndata -wi-a-----   1.00g
  data_un    ndata -wi-a-----   1.00g
  root       rl    -wi-ao----  <6.20g
  swap       rl    -wi-ao---- 820.00m
```

> Formater les partition en ext4 :  

```
[lackadmin@node1 ~]$ sudo mkfs -t ext4 /dev/ndata/data_un
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 10abd851-559a-409f-9551-d2b5227aa017
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

(Je répète ça pour les 2 autres partitions)

> Montage des partitions :  

```
[lackadmin@node1 ~]$ sudo mount /dev/ndata/data_un /mnt/data1
[lackadmin@node1 ~]$ sudo mount /dev/ndata/data_deux /mnt/data2
[lackadmin@node1 ~]$ sudo mount /dev/ndata/data_trois /mnt/data3
[lackadmin@node1 ~]$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
[...]
/dev/mapper/rl-root           6.2G  2.1G  4.2G  33% /
/dev/sda1                    1014M  240M  775M  24% /boot
tmpfs                         182M     0  182M   0% /run/user/1001
/dev/mapper/ndata-data_un     976M  2.6M  907M   1% /mnt/data1
/dev/mapper/ndata-data_deux   976M  2.6M  907M   1% /mnt/data2
/dev/mapper/ndata-data_trois  976M  2.6M  907M   1% /mnt/data3
```

> Config du Montage automatique des partitions au démarrage :  

```
[lackadmin@node1 ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Wed Sep 15 13:25:15 2021
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=90bc4519-60f2-4d96-af89-a6a979e63071 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
/dev/ndata/data_un      /mtn/data1              ext4    defaults        0 0
/dev/ndata/data_deux      /mtn/data2              ext4    defaults        0 0
/dev/ndata/data_trois      /mtn/data3              ext4    defaults        0 0
```

---

## D -- Gestion et Création de services :  

### Actions sur un service existant :  

- Si le service est en route :  

```
[lackadmin@node1 ~]$ sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2021-09-26 18:28:12 CEST; 58min ago
     Docs: man:firewalld(1)
 Main PID: 820 (firewalld)
    Tasks: 2 (limit: 11398)
   Memory: 30.6M
   CGroup: /system.slice/firewalld.service
           └─820 /usr/libexec/platform-python -s /usr/sbin/firewalld --nofork --nopid

Sep 26 18:28:11 node1.tp1.b2 systemd[1]: Starting firewalld - dynamic firewall daemon...
Sep 26 18:28:12 node1.tp1.b2 systemd[1]: Started firewalld - dynamic firewall daemon.
Sep 26 18:28:12 node1.tp1.b2 firewalld[820]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configu>
lines 1-13/13 (END)
```

- Si le service est activé (démarrage au boot)

```
[lackadmin@node1 ~]$ sudo systemctl is-enabled firewalld
enabled
```

---

### Création d'un service à part entière :  

Création du fichier web.service dans `/etc/systemd/system` :

```
[lackadmin@node1 system]$ cat web.service
[Unit]
Description=Very simple web service

[Service]
ExecStart=/bin/python3 -m http.server 8888

[Install]
WantedBy=multi-user.target
```

Vérification du fonctionnement du service après le démarrage : 

```
[lackadmin@node1 system]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```

> Le résultat de la commande curl prouve le fonctionnement du service

### Modification du service :  

Après avoir modifié le service et ajouté un fichier dans `srv/server-web/`
on teste le résultat avec un `curl 10.101.1.11:8888` :  

```
[lackadmin@node1 ~]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="salut.md">salut.md</a></li>
</ul>
<hr>
</body>
</html>
```

> Le fichier que j'ai ajouté précédemment est présent dans le serveur web.