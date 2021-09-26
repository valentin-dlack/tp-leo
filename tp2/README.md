# Réseau -- TP.2 : Routage  

- [Réseau -- TP.2 : Routage](#réseau----tp2--routage)
  - [1. ARP :](#1-arp-)
    - [**1.A : Échange ARP**](#1a--échange-arp)
    - [**1.B Analyse De Trames :**](#1b-analyse-de-trames-)
  - [2. Routage :](#2-routage-)
    - [**1. Mise en place du routage :**](#1-mise-en-place-du-routage-)
    - [**2. Analyse de trame :**](#2-analyse-de-trame-)
    - [**Accès à internet :**](#accès-à-internet-)
    - [**Analyse des trames internet :**](#analyse-des-trames-internet-)
  - [3. DHCP](#3-dhcp)
    - [**1. Mise en place du DHCP**](#1-mise-en-place-du-dhcp)
    - [**2. Amélioration du DHCP**](#2-amélioration-du-dhcp)
    - [**3. Analyse des trames :**](#3-analyse-des-trames-)

## 1. ARP :  
### **1.A : Échange ARP**  

Après avoir setup les deux machines sur le même réseau. On vérifie les tables ARP et le ping.

Voici les tables ARP des deux machines après le ping :  
*node1*
```
$ ip neigh
10.2.1.12 dev enp0s8 lladdr 08:00:27:3c:70:7c STALE
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:4f REACHABLE
```
*node 2*
```
$ ip neigh
10.2.1.11 dev enp0s8 lladdr 08:00:27:bb:53:f4 STALE
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:4f REACHABLE
```
L'adresse MAC de `node2` dans la table de `node1` est `08:00:27:3c:70:7c`  
Inversement dans la table de `node2` pour `node1` c'est `08:00:27:bb:53:f4`  

Prouver que les adresses MAC sont bonnes :  
- MAC de `node2` dans la commande `ip neigh` de `node1` :  
  `08:00:27:3c:70:7c`
- MAC de `node2` en faisant `ip a` sur cette même machine :  
  ```
  enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:3c:70:7c brd ff:ff:ff:ff:ff:ff
    inet 10.2.1.12/24 brd 10.2.1.255 scope global noprefixroute enp0s8
  ```

L'adresse MAC est bien la même. Le résultat de la table arp est donc valide.

---

### **1.B Analyse De Trames :**  

Après avoir fait une lecture des trames avec tcpdump et avoir exporté le .pcap on analyse les trames avec wireshark :  

| ordre | type trame  | source                      | destination                 |
| ----- | ----------- | --------------------------- | --------------------------- |
| 1     | Requête ARP | `node1` `08:00:27:3c:70:7c` | Broadcast `FF:FF:FF:FF:FF`  |
| 2     | Réponse ARP | `node2` `08:00:27:bb:53:f4` | `node1` `08:00:27:3c:70:7c` |
  
---

## 2. Routage :  

### **1. Mise en place du routage :**

Après avoir créer une nouvelle machine puis configurer le routeur pour qu'il fonctionne correctement.

On ajoute les routes permanentes dans la config puis on test avec un ping :

- Pour `node1` :  
```
[lack@node1 ~]$ cat /etc/sysconfig/network-scripts/route-enp0s8
10.2.2.12/24 via 10.2.1.254 dev enp0s8
[lack@node1 ~]$ ping 10.2.2.12
PING 10.2.2.12 (10.2.2.12) 56(84) bytes of data.
64 bytes from 10.2.2.12: icmp_seq=1 ttl=63 time=0.712 ms
64 bytes from 10.2.2.12: icmp_seq=2 ttl=63 time=0.850 ms
64 bytes from 10.2.2.12: icmp_seq=3 ttl=63 time=0.800 ms
64 bytes from 10.2.2.12: icmp_seq=4 ttl=63 time=0.785 ms
^C
--- 10.2.2.12 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3085ms
rtt min/avg/max/mdev = 0.712/0.786/0.850/0.060 ms
```

- Pour `marcel` :  
```
[lack@marcel ~]$ cat /etc/sysconfig/network-scripts/route-enp0s8
10.2.1.11/24 via 10.2.1.254 dev enp0s8
[lack@marcel ~]$ ping 10.2.1.11
PING 10.2.1.11 (10.2.1.11) 56(84) bytes of data.
64 bytes from 10.2.1.11: icmp_seq=1 ttl=63 time=1.23 ms
64 bytes from 10.2.1.11: icmp_seq=2 ttl=63 time=0.587 ms
64 bytes from 10.2.1.11: icmp_seq=3 ttl=63 time=0.650 ms
64 bytes from 10.2.1.11: icmp_seq=4 ttl=63 time=0.770 ms
^C
--- 10.2.1.11 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3081ms
rtt min/avg/max/mdev = 0.587/0.810/1.234/0.254 ms
```

---

### **2. Analyse de trame :**

On vide les tables ARP puis, on ping `marcel` depuis `node1` pour génerer du trafic :  

Voici les tables ARP des trois noeuds après le ping :

Node `router.net2.tp2` :  

```
[lack@router ~]$ ip neigh show
10.2.2.12 dev enp0s9 lladdr 08:00:27:bc:c4:cd REACHABLE
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:4f DELAY
10.2.1.11 dev enp0s8 lladdr 08:00:27:bb:53:f4 REACHABLE
```

Node `node1.net1.tp2` :  

```
[lack@node1 ~]$ ip neigh show
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:4f REACHABLE
10.2.1.254 dev enp0s8 lladdr 08:00:27:3c:70:7c REACHABLE
```

Node de `marcel.net2.tp2` :  

```
[lack@node1 ~]$ ip neigh show
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:4f REACHABLE
10.2.1.254 dev enp0s8 lladdr 08:00:27:3c:70:7c REACHABLE
```

> On observe que les machines qui se ping entre elles n'atteignent que les IP du routeur. Le routeur lui, a dans sa table ARP, l'IP/MAC des deux machines qui l'ont utilisé pour communiquer. Notre routage est donc fonctionnel.

| ordre | type trame  | IP source  | MAC source                   | IP destination | MAC destination              |
| ----- | ----------- | ---------- | ---------------------------- | -------------- | ---------------------------- |
| 1     | Requête ARP | 10.2.1.11  | `node1` `08:00:27:bb:53:f4`  | 10.2.1.254     | Broadcast `FF:FF:FF:FF:FF`   |
| 2     | Réponse ARP | 10.2.1.254 | `router` `08:00:27:3c:70:7c` | 10.2.1.11      | `node1` `08:00:27:bb:53:f4`  |
| 3     | Requête ARP | 10.2.2.254 | `router` `08:00:27:3c:70:7c` | 10.2.2.12      | Broadcast `FF:FF:FF:FF:FF`   |
| 4     | Réponse ARP | 10.2.2.12  | `marcel` `08:00:27:bc:c4:cd` | 10.2.2.254     | `router` `08:00:27:3c:70:7c` |
| 5     | Ping        | 10.2.1.11  | `node1` `08:00:27:bb:53:f4`  | 10.2.2.12      | `marcel` `08:00:27:bc:c4:cd` |
| 6     | Pong        | 10.2.2.12  | `marcel` `08:00:27:bc:c4:cd` | 10.2.1.11      | `node1` `08:00:27:bb:53:f4`  |

---

### **Accès à internet :**  

On ajoute une route par défaut à `node1` et `marcel` :  

Pour `node1` :  

```
[lack@node1 ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
IPADDR=10.2.1.11
NETMASK=255.255.255.0
[...]
GATEWAY=10.2.1.254
```

Pour `marcel` :  

```
[lack@marcel ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
IPADDR=10.2.2.12
NETMASK=255.255.255.0
[...]
GATEWAY=10.2.2.254
```

On teste ça avec un `ping 8.8.8.8`, on ajoutera après un DNS pour qu'il puisse ping avec un nom de domaine :  

```
------ NODE1 :
[lack@node1 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=19.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=19.3 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=19.3 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=19.4 ms
^C
--- 8.8.8.8 ping statistics ---

------ MARCEL :
[lack@marcel ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=19.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=19.6 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=19.8 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=19.2 ms
^C
--- 8.8.8.8 ping statistics ---
```

On ajoute `DNS1 = 1.1.1.1` dans le dossier de config de `enp0s8` pour qu'on puisse utiliser un nom de domaine.

On test d'abord avec un `dig google.com` :  

- Pour node1 :  

```
[lack@node1 ~]$ dig google.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> google.com
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 28019
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             262     IN      A       142.250.75.238

;; Query time: 18 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Thu Sep 23 16:58:42 CEST 2021
;; MSG SIZE  rcvd: 55
```

- Pour marcel :  

```
[lack@marcel ~]$ dig google.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> google.com
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19339
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             256     IN      A       216.58.209.238

;; Query time: 19 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Thu Sep 23 16:58:47 CEST 2021
;; MSG SIZE  rcvd: 55
```

> On voit que le serveur utilisé est bien `1.1.1.1` comme configuré dans `enp0s8`  


Puis ensuite avec un `ping google.com` :  

- Pour node1 :  

```
[lack@node1 ~]$ ping google.com
PING google.com (142.250.75.238) 56(84) bytes of data.
64 bytes from par10s41-in-f14.1e100.net (142.250.75.238): icmp_seq=1 ttl=113 time=18.1 ms
64 bytes from par10s41-in-f14.1e100.net (142.250.75.238): icmp_seq=2 ttl=113 time=18.9 ms
64 bytes from par10s41-in-f14.1e100.net (142.250.75.238): icmp_seq=3 ttl=113 time=18.2 ms
64 bytes from par10s41-in-f14.1e100.net (142.250.75.238): icmp_seq=4 ttl=113 time=17.7 ms
^C
--- google.com ping statistics ---
```

- Pour marcel :  

```
[lack@marcel ~]$ ping google.com
PING google.com (216.58.214.78) 56(84) bytes of data.
64 bytes from fra15s10-in-f14.1e100.net (216.58.214.78): icmp_seq=1 ttl=113 time=18.4 ms
64 bytes from fra15s10-in-f14.1e100.net (216.58.214.78): icmp_seq=2 ttl=113 time=18.8 ms
64 bytes from fra15s10-in-f14.1e100.net (216.58.214.78): icmp_seq=3 ttl=113 time=19.2 ms
64 bytes from fra15s10-in-f14.1e100.net (216.58.214.78): icmp_seq=4 ttl=113 time=19.1 ms
^C
--- google.com ping statistics ---
```

---

### **Analyse des trames internet :**

| ordre | type trame | IP source           | MAC source                   | IP destination | MAC destination     |     |
| ----- | ---------- | ------------------- | ---------------------------- | -------------- | ------------------- | --- |
| 1     | ping       | `node1` `10.2.1.11` | `node1` `08:00:27:bb:53:f4`  | `8.8.8.8`      | `08:00:27:3c:70:7c` |     |
| 2     | pong       | `google` `8.8.8.8`  | `google` `08:00:27:3c:70:7c` | `10.2.1.11`    | `08:00:27:bb:53:f4` | ... |

---

## 3. DHCP

### **1. Mise en place du DHCP**  

Configuration du service dhcpd

```
[lack@router ~]$ sudo cat /etc/dhcp/dhcpd.conf

default-lease-time 900;
max-lease-time 10800;
ddns-update-style none;
authoritative;

option domain-name-servers 1.1.1.1;
subnet 10.2.1.0 netmask 255.255.255.0 {
        range dynamic-bootp 10.2.1.2 10.2.1.253;
        option routers 10.2.1.254;
}
```

Preuve que `node2` a une IP attribuée par le serveur DHCP :  

- Avec un `ip a` sur node2 : 

```
[lack@node2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:85:4f:18 brd ff:ff:ff:ff:ff:ff
    inet 10.2.1.2/24 brd 10.2.1.255 scope global dynamic noprefixroute enp0s8
       valid_lft 843sec preferred_lft 843sec
    inet6 fe80::a00:27ff:fe85:4f18/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

- Avec les leases du serveur DHCP :  

```
[lack@router ~]$ cat /var/lib/dhcpd/dhcpd.leases

lease 10.2.1.2 {
  starts 4 2021/09/23 15:46:13;
  ends 4 2021/09/23 16:01:13;
  cltt 4 2021/09/23 15:46:13;
  binding state active;
  next binding state free;
  rewind binding state free;
  hardware ethernet 08:00:27:85:4f:18;
  uid "\001\010\000'\205O\030";
  client-hostname "node2";
}
```

---

### **2. Amélioration du DHCP**

> Le fichier lease ci-dessus montre que node2 a son IP

Ping de node2 vers la passerelle :  

```
[lack@node2 ~]$ ping 10.2.1.254
PING 10.2.1.254 (10.2.1.254) 56(84) bytes of data.
64 bytes from 10.2.1.254: icmp_seq=1 ttl=64 time=0.386 ms
64 bytes from 10.2.1.254: icmp_seq=2 ttl=64 time=0.302 ms
64 bytes from 10.2.1.254: icmp_seq=3 ttl=64 time=0.380 ms
64 bytes from 10.2.1.254: icmp_seq=4 ttl=64 time=0.332 ms
^C
--- 10.2.1.254 ping statistics ---
```

Vérification avec `ip r s` :  

```
[lack@node2 ~]$ ip r s
default via 10.2.1.254 dev enp0s8 proto dhcp metric 100
10.2.1.0/24 dev enp0s8 proto kernel scope link src 10.2.1.2 metric 100
```

On voit bien qu'il possède une route par défaut.

On ping une IP "random" pour vérifier le fonctionnement. Ici `8.8.8.8` :  

```
[lack@node2 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=19.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=19.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=19.0 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=19.9 ms
^C
--- 8.8.8.8 ping statistics ---
```

On va tester maintenant le DNS avec un `dig ynov.com` et un `ping ynov.com` :  

- `dig ynov.com` :

```
[lack@node2 ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23880
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               3290    IN      A       92.243.16.143

;; Query time: 19 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Thu Sep 23 17:59:05 CEST 2021
;; MSG SIZE  rcvd: 53
```

- `ping ynov.com` :

```
[lack@node2 ~]$ ping ynov.com
PING ynov.com (92.243.16.143) 56(84) bytes of data.
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=1 ttl=52 time=17.9 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=2 ttl=52 time=17.10 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=3 ttl=52 time=17.9 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=4 ttl=52 time=18.1 ms
^C
--- ynov.com ping statistics ---
```

---

### **3. Analyse des trames :**

Voici une analyse des trames DHCP et ARP prises sur le routeur, pendant la récupération d'une nouvelle IP par node2

| ordre | type trame    | IP source  | MAC source                   | IP destination  | MAC destination               |
| ----- | ------------- | ---------- | ---------------------------- | --------------- | ----------------------------- |
| 1     | Requête ARP   | 10.2.1.2   | `node2` `08:00:27:85:4f:18`  | 10.2.1.254      | `router` `08:00:27:3c:70:7c`  |
| 2     | Réponse ARP   | 10.2.1.254 | `router` `08:00:27:3c:70:7c` | 10.2.1.2        | `node2` `08:00:27:85:4f:18`   |
| 3     | Requête ARP   | 10.2.2.254 | `router` `08:00:27:3c:70:7c` | 10.2.2.2        | `node2` `08:00:27:85:4f:18`   |
| 4     | Réponse ARP   | 10.2.2.2   | `node2` `08:00:27:85:4f:18`  | 10.2.2.254      | `router` `08:00:27:3c:70:7c`  |
| 5     | DHCP Discover | 0.0.0.0    | `router` `08:00:27:3c:70:7c` | 255.255.255.255 | Broadcast `ff:ff:ff:ff:ff:ff` |
| 6     | DHCP Offer    | 10.2.1.254 | `router` `08:00:27:3c:70:7c` | 10.2.1.3        | `node2` `08:00:27:85:4f:18`   |
| 5     | DHCP Request  | 0.0.0.0    | `node2` `08:00:27:85:4f:18`  | 255.255.255.255 | Broadcast `ff:ff:ff:ff:ff:ff` |
| 6     | DHCP Ack      | 10.2.1.254 | `router` `08:00:27:3c:70:7c` | 10.2.1.3        | `node2` `08:00:27:85:4f:18`   |

> On reconnait le fonctionnement du protocol DHCP grâce au "DORA (Discover, Offer, Request, Acknowledge)" qu'on observe dans les 4 dernières trames.

