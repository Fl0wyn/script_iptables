Installation de iptables et ipset sur Debian :
```bash
apt install iptables ipset
```
#
Copier la listes des règles iptables dans le fichier /root/firewall.sh et les modifier si besoin puis rendez le exécutable
```bash
curl -L https://git.io/JeSL5 > /root/firewall.sh
chmod +x /root/firewall.sh
```
(Vous pouvez créer un fichier banip.txt et y ajouter des ip à bannir manuelement).
#

Tester et vérifier l'exécution du script :
```bash
bash /root/firewall.sh
iptables -L
```
#
Rendre les règles non-volatiles :
```bash
iptables-save > /etc/firewall.conf
```
#
Ouvrez `/etc/network/if-up.d/iptables` et ajoutez ce qui suit :
```bash
#!/bin/bash
iptables-restore < /etc/firewall.conf
```
#
Le rendre exécutable :
```bash
chmod +x /etc/network/if-up.d/iptables
```
#
Pour modifier les Règles :
```bash
vim /root/firewall.sh
bash /root/firewall.sh
iptables-save > /etc/firewall.conf
```
#
Voir les IP bannies depuis le fihier `banip.txt`
```bash
iptables -L INPUT -nv --line-numbers | grep DROP
```
#
Voir les IP bannies depuis ipset
```bash
ipset -L
```
