# TP3 : Progressons vers le réseau d'infrastructure

- [TP3 : Progressons vers le réseau d'infrastructure](#tp3--progressons-vers-le-réseau-dinfrastructure)
  - [1. Architecture réseau](#1-architecture-réseau)


## 1. Architecture réseau

Pour commencer sur l'infrastructure, voici une table des réseau :

| Nom du réseau | Adresse du réseau | Masque            | Nombre de clients possibles | Adresse passerelle | Adresse Broadcast |
| ------------- | ----------------- | ----------------- | --------------------------- | ------------------ | ----------------- |
| `client1`     | `10.3.1.129`      | `255.255.255.192` | 62                          | `10.3.1.190`       | `10.3.1.191`      |
| `server1`     | `10.3.1.1`        | `255.255.255.128` | 126                         | `10.3.1.126`       | `10.3.1.127`      |
| `server2`     | `10.3.1.192`      | `255.255.255.240` | 14                          | `10.3.1.206`       | `10.3.1.207`      |

Ainsi que le début du tableau d'adressage : 

| Nom machine  | Adresse IP `client1` | Adresse IP `server1` | Adresse IP `server2` | Adresse de passerelle |
| ------------ | -------------------- | -------------------- | -------------------- | --------------------- |
| `router.tp3` | `10.3.1.190/26`      | `10.3.1.126/25`      | `10.3.1.206/28`      | Carte NAT             |
| ...          | ...                  | ...                  | ...                  | `10.3.?.?/?`          |

