# TP4 : Vers un réseau d'entreprise

# 1. Dumb switch

## Setup topologie n°1 

On ajoute les ip aux VPCS : 

```
PC1> ip 10.1.1.1/24 
```

```
PC2> ip 10.1.1.2/24
```

On ping de PC1 vers PC2 pour voir si cela fonctionne :  

```
PC1> ping 10.1.1.2

84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=1.256 ms
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=4.753 ms
84 bytes from 10.1.1.2 icmp_seq=3 ttl=64 time=1.969 ms
84 bytes from 10.1.1.2 icmp_seq=4 ttl=64 time=1.711 ms
```

# 2. VLAN

## Setup topologie n°2

On ajoute un PC3 et on lui donne une IP :  

```
PC3> ip 10.1.1.3/24
Checking for duplicate address...
PC3 : 10.1.1.3 255.255.255.0
```

On ping pour vérifier que tout est connecté :  

```
PC3> ping 10.1.1.1
84 bytes from 10.1.1.1 icmp_seq=1 ttl=64 time=3.864 ms
84 bytes from 10.1.1.1 icmp_seq=2 ttl=64 time=3.692 ms
84 bytes from 10.1.1.1 icmp_seq=3 ttl=64 time=3.393 ms

PC3> ping 10.1.1.2
84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=2.659 ms
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=2.225 ms
84 bytes from 10.1.1.2 icmp_seq=3 ttl=64 time=3.485 ms
```

## Config VLANs :  

> Nos deux VLANs s'appellerons admins (10) et guests (20) comme dans l'exemple

```
Switch(config)# vlan 10
Switch(config-vlan)# name admins
Switch(config-vlan)# exit
Switch(config)# vlan 20
Switch(config-vlan)# name guests
Switch(config-vlan)# exit
Switch(config)# exit
Switch# show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Gi0/0, Gi0/1, Gi0/2, Gi0/3
                                                Gi1/0, Gi1/1, Gi1/2, Gi1/3
                                                Gi2/0, Gi2/1, Gi2/2, Gi2/3
                                                Gi3/0, Gi3/1, Gi3/2, Gi3/3
10   admins                           active
20   guests                           active
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup
```

On voit que les deux VLANs que nous venons de créer sont actifs. Il faut maintenant les attribuer a des ports

```
Switch(config)#interface Gi0/0
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 10
Switch(config-if)#exit
Switch(config)#interface Gi0/1
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 10
Switch(config-if)#exit
Switch(config)#interface Gi0/2
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 20
Switch(config-if)#exit
```

> Les ports ont leurs vlans attribués.

Maintenant, PC1 et PC2 devraient toujours pouvoir se ping alors que PC3 ne peut plus ping personne :  

- PC1 -> PC2

```
PC1> ping 10.1.1.2
84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=0.763 ms
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=1.567 ms
84 bytes from 10.1.1.2 icmp_seq=3 ttl=64 time=1.396 ms
84 bytes from 10.1.1.2 icmp_seq=4 ttl=64 time=2.337 ms
```

PC3 -> PC1

```
PC3> ping 10.1.1.1

host (10.1.1.1) not reachable
```

PC3 -> PC2

```
PC3> ping 10.1.1.2

host (10.1.1.2) not reachable
```

# 3. Routing 

## Setup topologie n°3

- Adressage :

> PC1 et PC2 on déjà leurs ip qui sont config.

ADM1 :  

```
adm1> ip 10.2.2.1/24
Checking for duplicate address...
adm1 : 10.2.2.1 255.255.255.0

adm1> wr
```

WEB server :  

```
[lack@web ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s3
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
IPADDR=10.3.3.1
NETMASK=255.255.255.0
```

On ajoute et configure les VLANs sur les ports du switch :  


**Config du port routeur en mode trunk :**  

```
Switch(config)#interface Gi0/0
Switch(config-if)#switchport trunk encapsulation dot1q
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport truck vlan add 11,12,13
                                ^
% Invalid input detected at '^' marker.

Switch(config-if)#switchport trunk vlan add 11,12,13
                                   ^
% Invalid input detected at '^' marker.

Switch(config-if)#switchport trunk allowed vlan add 11,12,13
Switch(config-if)#exit

```

- **Reste de la configuration :**  

```
Switch#show vlan br

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Gi1/1, Gi1/2, Gi1/3, Gi2/0
                                                Gi2/1, Gi2/2, Gi2/3, Gi3/0
                                                Gi3/1, Gi3/2, Gi3/3
11   clients                          active    Gi0/1, Gi0/2
12   admins                           active    Gi0/3
13   servers                          active    Gi1/0
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup
```
---
## Setup routeur :  

Ajout des IPs statiques sur une seule interface :  

```
R1(config)#interface fastEthernet 0/0.11
R1(config-subif)#encapsulation dot1Q 11
R1(config-subif)#ip addr 10.1.1.254 255.255.255.0
R1(config-subif)#exit
#
R1(config)#interface fastEthernet 0/0.12
R1(config-subif)#encapsulation dot1Q 12
R1(config-subif)#ip addr 10.2.2.254 255.255.255.0
R1(config-subif)#exit
#
R1(config)#interface fastEthernet 0/0.13
R1(config-subif)#encapsulation dot1Q 13
R1(config-subif)#ip addr 10.3.3.254 255.255.255.0
R1(config-subif)#exit
```

On vérifie que les IPs sont bien assignés :  

```
R1#show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            unassigned      YES unset  administratively down down                                 
FastEthernet0/0.11         10.1.1.254      YES manual administratively down down                                 
FastEthernet0/0.12         10.2.2.254      YES manual administratively down down                                 
FastEthernet0/0.13         10.3.3.254      YES manual administratively down down
```

> Il faut activer les interfaces pour que cela fonctionne correctement.  
> Un `no shut` sur l'interface FastEthernet 0/0 suffira.
---
## Test du routeur :  

- Test d'un ping dans son réseau :  

PC1 -> Routeur(10.1.1.254/24) :  

```
PC1> ping 10.1.1.254
84 bytes from 10.1.1.254 icmp_seq=1 ttl=255 time=19.951 ms
84 bytes from 10.1.1.254 icmp_seq=2 ttl=255 time=7.390 ms
84 bytes from 10.1.1.254 icmp_seq=3 ttl=255 time=7.153 ms
84 bytes from 10.1.1.254 icmp_seq=4 ttl=255 time=14.388 ms
```
PC2 -> Routeur(10.1.1.254/24) :  

```
PC2> ping 10.1.1.254
84 bytes from 10.1.1.254 icmp_seq=1 ttl=255 time=9.951 ms
84 bytes from 10.1.1.254 icmp_seq=2 ttl=255 time=12.039 ms
84 bytes from 10.1.1.254 icmp_seq=3 ttl=255 time=7.445 ms
84 bytes from 10.1.1.254 icmp_seq=4 ttl=255 time=3.947 ms
```
ADM1 -> Routeur(10.2.2.254/24) :  

```
adm1> ping 10.2.2.254
84 bytes from 10.2.2.254 icmp_seq=1 ttl=255 time=9.532 ms
84 bytes from 10.2.2.254 icmp_seq=2 ttl=255 time=13.072 ms
84 bytes from 10.2.2.254 icmp_seq=3 ttl=255 time=8.133 ms
84 bytes from 10.2.2.254 icmp_seq=4 ttl=255 time=16.045 ms
```

Serv Web -> Routeur(10.3.3.254/24) :  

```
[lack@web ~]$ ping 10.3.3.254 -c 2
PING 10.3.3.254 (10.3.3.254) 56(84) bytes of data.
64 bytes from 10.3.3.254: icmp_seq=1 ttl=255 time=8.10 ms
64 bytes from 10.3.3.254: icmp_seq=2 ttl=255 time=7.01 ms

--- 10.3.3.254 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 7.006/7.550/8.095/0.551 ms
```

Les ping dans les mêmes réseaux fonctionnent. Il faut maintenant configurer les routes par défauts.

- PC1 :  

```
PC1> ip 10.1.1.1/24 10.1.1.254
Checking for duplicate address...
PC1 : 10.1.1.1 255.255.255.0 gateway 10.1.1.254
```

- PC2 :  

```
PC2> ip 10.1.1.2/24 10.1.1.254
Checking for duplicate address...
PC2 : 10.1.1.2 255.255.255.0 gateway 10.1.1.254
```

- ADM1 :  

```
adm1> ip 10.2.2.1/24 10.2.2.254
Checking for duplicate address...
adm1 : 10.2.2.1 255.255.255.0 gateway 10.2.2.254
```

- Serv Web :  

```
[lack@web ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s3 | grep GATEWAY
GATEWAY=10.3.3.254
```

- **Les routes par défaut sont ajoutées, on teste tout ça avec des pings à travers les différents réseaux :**  

- PC1 -> WebServer

```
PC1> ping 10.3.3.1
84 bytes from 10.3.3.1 icmp_seq=1 ttl=63 time=18.616 ms
84 bytes from 10.3.3.1 icmp_seq=2 ttl=63 time=15.480 ms
84 bytes from 10.3.3.1 icmp_seq=3 ttl=63 time=19.416 ms
84 bytes from 10.3.3.1 icmp_seq=4 ttl=63 time=19.287 ms
```

ADM1 -> PC1

```
adm1> ping 10.1.1.1
84 bytes from 10.1.1.1 icmp_seq=1 ttl=63 time=31.108 ms
84 bytes from 10.1.1.1 icmp_seq=2 ttl=63 time=18.746 ms
84 bytes from 10.1.1.1 icmp_seq=3 ttl=63 time=19.635 ms
84 bytes from 10.1.1.1 icmp_seq=4 ttl=63 time=14.467 ms
```

ADM1 -> WebServer

```
ping 10.3.3.1
84 bytes from 10.3.3.1 icmp_seq=1 ttl=63 time=20.497 ms
84 bytes from 10.3.3.1 icmp_seq=2 ttl=63 time=21.122 ms
84 bytes from 10.3.3.1 icmp_seq=3 ttl=63 time=23.910 ms
84 bytes from 10.3.3.1 icmp_seq=4 ttl=63 time=18.840 ms
```

> Le routeur fontionne parfaitement, on peut passer au...

# 4. NAT

## Setup topologie n°4  

### Ajout du cloud dans la topologie.  

- Récupération de l'IP en DHCP :  

```
R1(config)#interface FastEthernet 1/0
R1(config-if)#ip address dhcp
R1(config-if)#no shut
```

On vérifie que l'ip est bien attribuée :  

```
R1#show ip int br
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            unassigned      YES NVRAM  up                    up  
FastEthernet0/0.11         10.1.1.254      YES NVRAM  up                    up  
FastEthernet0/0.12         10.2.2.254      YES NVRAM  up                    up  
FastEthernet0/0.13         10.3.3.254      YES NVRAM  up                    up  
FastEthernet1/0            10.0.3.16       YES DHCP   up                    up  
```

### Configuration du NAT :  

- Config des interfaces externes :  

```
R1(config)#interface fastEthernet 1/0
R1(config-if)#ip nat outside
R1(config-if)#exit
```

- Puis les interfaces internes :  

```
R1(config)#interface fastEthernet 0/0
R1(config-if)#ip nat inside
*Mar  1 00:44:46.639: %LINEPROTO-5-UPDOWN: Line protocol on Interface NVI0, changed state to up
R1(config-if)#exit
```

- Configuration du NAT en lui-même :  

```
R1(config)#access-list 1 permit any
R1(config)#ip nat inside source list 1 interface fastEthernet 1/0 overload
```

### Test du NAT (sans DNS) :  

- Ping de `1.1.1.1` :  

```
PC2> ping 1.1.1.1

84 bytes from 1.1.1.1 icmp_seq=1 ttl=56 time=30.989 ms
84 bytes from 1.1.1.1 icmp_seq=2 ttl=56 time=29.562 ms
84 bytes from 1.1.1.1 icmp_seq=3 ttl=56 time=33.057 ms
84 bytes from 1.1.1.1 icmp_seq=4 ttl=56 time=25.928 ms
```

> Le NAT fonctionne, il faut maintenant ajouter un DNS pour résoudre les noms de domaine.

- Ajout d'un serveur DNS sur les VPCS :  

Pour ça il suffit juste de faire ` ip dns 8.8.8.8`

- Ajout d'un serveur DNS sur le serveur web :  

```
[lack@web ~]$ sudo cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 8.8.8.8
```

- Test avec les noms de domaines :  

PC1 > ynov.com

```
PC1> ping ynov.com
ynov.com resolved to 92.243.16.143

84 bytes from 92.243.16.143 icmp_seq=1 ttl=52 time=29.101 ms
84 bytes from 92.243.16.143 icmp_seq=2 ttl=52 time=30.839 ms
84 bytes from 92.243.16.143 icmp_seq=3 ttl=52 time=33.041 ms
84 bytes from 92.243.16.143 icmp_seq=4 ttl=52 time=31.359 ms
```

ADM1 > ynov.com  

```
adm1> ping ynov.com
ynov.com resolved to 92.243.16.143

84 bytes from 92.243.16.143 icmp_seq=1 ttl=52 time=30.498 ms
84 bytes from 92.243.16.143 icmp_seq=2 ttl=52 time=29.069 ms
84 bytes from 92.243.16.143 icmp_seq=3 ttl=52 time=28.098 ms
84 bytes from 92.243.16.143 icmp_seq=4 ttl=52 time=36.024 ms

```

WebServer > ynov.com  

```
[lack@web ~]$ ping ynov.com -c 2
PING ynov.com (92.243.16.143) 56(84) bytes of data.
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=1 ttl=52 time=29.1 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=2 ttl=52 time=26.8 ms

--- ynov.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 26.834/27.968/29.103/1.146 ms
```

> Le NAT fonctionne et nos machines ont maintenant un accès internet et une résolution de nom !

# 5. Ajouter un Batiment

## Setup topologie n°5  

- Fichiers de configuration du matériel réseaux :  

  - Switch sw1 : [[ Ici ]](./conf/config-sw1.txt)
  - Switch sw2 : [[ Ici ]](./conf/config-sw2.txt)
  - Switch sw3 : [[ Ici ]](./conf/config-sw3.txt)
  - Routeur R1 : [[ Ici ]](./conf/config-router1.txt)

## Vérification du DHCP :  

Fichier de configuration du DHCP : [[ Ici ]](./conf/dhcpd.conf)

- PC3 :  
  - Avoir une IP en DHCP :  
  
    ```
    PC3> show ip
    NAME        : PC3[1]
    IP/MASK     : 10.1.1.10/24
    GATEWAY     : 10.1.1.254
    DNS         : 8.8.8.8
    DHCP SERVER : 10.1.1.253
    DHCP LEASE  : 753, 900/450/787
    MAC         : 00:50:79:66:68:03
    LPORT       : 20128
    RHOST:PORT  : 127.0.0.1:20129
    MTU         : 1500
    ```

  - Ping Serveur Web :  

    ```
    PC3> ping 10.3.3.1
    84 bytes from 10.3.3.1 icmp_seq=1 ttl=63 time=42.642 ms
    84 bytes from 10.3.3.1 icmp_seq=2 ttl=63 time=26.504 ms
    84 bytes from 10.3.3.1 icmp_seq=3 ttl=63 time=40.971 ms
    84 bytes from 10.3.3.1 icmp_seq=4 ttl=63 time=39.964 ms
    ```

  - Ping 8.8.8.8 :  

    ```
    PC3> ping 8.8.8.8
    84 bytes from 8.8.8.8 icmp_seq=1 ttl=112 time=45.976 ms
    84 bytes from 8.8.8.8 icmp_seq=2 ttl=112 time=36.463 ms
    84 bytes from 8.8.8.8 icmp_seq=3 ttl=112 time=49.499 ms
    84 bytes from 8.8.8.8 icmp_seq=4 ttl=112 time=41.410 ms
    ```

  - Ping google.com :  

    ```
    PC3> ping google.com
    google.com resolved to 142.250.74.238

    84 bytes from 142.250.74.238 icmp_seq=1 ttl=113 time=50.787 ms
    84 bytes from 142.250.74.238 icmp_seq=2 ttl=113 time=57.631 ms
    84 bytes from 142.250.74.238 icmp_seq=3 ttl=113 time=53.380 ms
    84 bytes from 142.250.74.238 icmp_seq=4 ttl=113 time=51.937 ms
    ```

- PC4 :  
  - Avoir une IP en DHCP :  
  
    ```
    PC4> ip dhcp
    DDORA IP 10.1.1.11/24 GW 10.1.1.254
    ```

  - Ping Serveur Web :  

    ```
    PC4> ping 10.3.3.1

    84 bytes from 10.3.3.1 icmp_seq=1 ttl=63 time=37.130 ms
    84 bytes from 10.3.3.1 icmp_seq=2 ttl=63 time=35.473 ms
    84 bytes from 10.3.3.1 icmp_seq=3 ttl=63 time=31.842 ms
    84 bytes from 10.3.3.1 icmp_seq=4 ttl=63 time=35.934 ms
    ```

  - Ping 8.8.8.8 :  

    ```
    PC4> ping 8.8.8.8
    8.8.8.8 icmp_seq=1 timeout
    84 bytes from 8.8.8.8 icmp_seq=2 ttl=112 time=51.742 ms
    84 bytes from 8.8.8.8 icmp_seq=3 ttl=112 time=47.324 ms
    84 bytes from 8.8.8.8 icmp_seq=4 ttl=112 time=46.465 ms

    ```

  - Ping google.com :  

    ```
    PC4> ping google.com
    google.com resolved to 216.58.215.46

    84 bytes from 216.58.215.46 icmp_seq=1 ttl=113 time=52.597 ms
    84 bytes from 216.58.215.46 icmp_seq=2 ttl=113 time=42.509 ms
    84 bytes from 216.58.215.46 icmp_seq=3 ttl=113 time=45.421 ms
    84 bytes from 216.58.215.46 icmp_seq=4 ttl=113 time=46.099 ms
    ```

- PC5 :  
  - Avoir une IP en DHCP :  
  
    ```
    PC5> ip dhcp
    DDORA IP 10.1.1.12/24 GW 10.1.1.254
    ```

  - Ping Serveur Web :  

    ```
    PC5> ping 10.3.3.1

    84 bytes from 10.3.3.1 icmp_seq=1 ttl=63 time=29.918 ms
    84 bytes from 10.3.3.1 icmp_seq=2 ttl=63 time=25.525 ms
    84 bytes from 10.3.3.1 icmp_seq=3 ttl=63 time=29.088 ms
    84 bytes from 10.3.3.1 icmp_seq=4 ttl=63 time=23.596 ms
    ```

  - Ping 8.8.8.8 :  

    ```
    PC5> ping 8.8.8.8

    8.8.8.8 icmp_seq=1 timeout
    84 bytes from 8.8.8.8 icmp_seq=2 ttl=112 time=44.913 ms
    84 bytes from 8.8.8.8 icmp_seq=3 ttl=112 time=45.791 ms
    84 bytes from 8.8.8.8 icmp_seq=4 ttl=112 time=56.959 ms
    ```

  - Ping google.com :  

    ```
    PC5> ping google.com
    google.com resolved to 216.58.215.46

    84 bytes from 216.58.215.46 icmp_seq=1 ttl=113 time=55.292 ms
    84 bytes from 216.58.215.46 icmp_seq=2 ttl=113 time=54.163 ms
    84 bytes from 216.58.215.46 icmp_seq=3 ttl=113 time=44.806 ms
    84 bytes from 216.58.215.46 icmp_seq=4 ttl=113 time=52.987 ms
    ```

> Et voilà, notre nouveau batiment avec le DHCP fonctionne !