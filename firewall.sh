######################
## FILTRAGE DE BASE ##
######################

# Vider les règles déjà existantes
iptables -F
iptables -X

# Refuser toutes les connexions
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Autoriser le trafic interne sur l'adresse de loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Autoriser une connexion déjà établie
iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

########################
## FILTRAGE PERSONNEL ##
########################

# SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# HTTP + HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# NTP
iptables -A INPUT -p tcp --dport 123 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 123 -j ACCEPT

# SMB
iptables -A INPUT -p tcp --dport 445 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 445 -j ACCEPT

# DNS
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

#####################
## FILTRAGE AVANCÉ ##
#####################

# Autoriser les types de paquets IMCP utiles
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type source-quench -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Empêcher les inondations de ping
iptables -N ICMPFLOOD
iptables -A ICMPFLOOD -m recent --name ICMP --set --rsource
iptables -A ICMPFLOOD -m recent --name ICMP --update --seconds 1 --hitcount 6 --rsource --rttl -m limit --limit 1/sec --limit-burst 1 -j LOG --log-prefix "iptables[ICMP-flood]: "
iptables -A ICMPFLOOD -m recent --name ICMP --update --seconds 1 --hitcount 6 --rsource --rttl -j DROP
iptables -A ICMPFLOOD -j ACCEPT

# Supprimez les paquets non conformes
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Supprimer tous les paquets NULL mal formés entrants
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Supprimer les paquets d'attaque syn-flood
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Supprimer les paquets XMAS mal formés entrants
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
