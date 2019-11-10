# 1 - Copier les règles iptables dans le fichier /root/firewall.sh

# 2 - Rendre le scripts executable :
sudo chmod +x /root/Scripts/firewall.sh

# 3 - terter et vérifier l'exécution du script :
sudo ./root/firewall.sh
sudo iptables -L

# 4 - Rendre les règles non-volatiles :
sudo iptables-save > /etc/firewall.conf

# 5 - Ouvrez /etc/network/if-up.d/iptables et ajoutez ce qui suit :
sudo vim /etc/network/if-up.d/iptables

#!/bin/sh
iptables-restore < /etc/firewall.conf

# 6 - Le rendre exécutable :
sudo chmod +x /etc/network/if-up.d/iptables

# 7 - Les règles seront restaurées à chaque démarrage du réseau !

# 8 - Pour modifier les Règles :
sudo vim /root/firewall.sh
./root/firewall.sh
sudo iptables-save > /etc/firewall.conf

# Voir les IP bannies depuis le fihier banip.txt
iptables -L INPUT -nv --line-numbers | grep DROP

# Voir les IP bannies depuis ipset
ipset -L
