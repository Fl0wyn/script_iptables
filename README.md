# Créer un script persistant pour des commandes Iptables 
####  Copier les règles iptables dans le fichier */root/firewall.sh*

#### Rendre le scripts executable :
```
chmod +x /root/scripts/firewall.sh
```
#### Tester et vérifier l'exécution du script :
```
bash /root/firewall.sh
```
```
iptables -L
```
#### Rendre les règles non-volatiles :
```
iptables-save > /etc/firewall.conf
```
#### Ouvrez */etc/network/if-up.d/iptables* et ajoutez ce qui suit :
```
#!/bin/bash
iptables-restore < /etc/firewall.conf
```
#### Le rendre exécutable :
```
chmod +x /etc/network/if-up.d/iptables
```
#### Pour modifier les Règles :
```
vim /root/firewall.sh
bash /root/firewall.sh
iptables-save > /etc/firewall.conf
```
#### Voir les IP bannies depuis le fihier *banip.txt*
```
iptables -L INPUT -nv --line-numbers | grep DROP
```
#### Voir les IP bannies depuis ipset
```
ipset -L
```
