#!/bin/bash

##################
## FILTRE BASIC ##
##################

# Réinitialise les règles
iptables -F
iptables -X

# Bloque tout le trafic
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Autorise les connexions déjà établies et localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

#######################
## FILTRE DE SERVICE ##
#######################

# SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# HTTP + HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# SMTP
iptables -A INPUT -p tcp --dport 465 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 465 -j ACCEPT

# IMAP
iptables -A INPUT -p tcp --dport 993 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 993 -j ACCEPT

# WHOIS
iptables -A INPUT -p tcp --dport 43 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 43 -j ACCEPT

# SMB
iptables -A INPUT -p tcp --dport 445 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 445 -j ACCEPT

# NTP
iptables -A INPUT -p tcp --dport 123 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 123 -j ACCEPT

# DNS
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

####################
## FILTRE AVANCEE ##
####################

# Autoriser les types de paquets IMCP utiles
# Prévenir les inondations ping
# Supprimer les paquets non valables / NULL / syn-flood / XMAS
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type source-quench -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -N ICMPFLOOD
iptables -A ICMPFLOOD -m recent --name ICMP --set --rsource
iptables -A ICMPFLOOD -m recent --name ICMP --update --seconds 1 --hitcount 6 --rsource --rttl -m limit --limit 1/sec --limit-burst 1 -j LOG --log-prefix "iptables[ICMP-flood]: "
iptables -A ICMPFLOOD -m recent --name ICMP --update --seconds 1 --hitcount 6 --rsource --rttl -j DROP
iptables -A ICMPFLOOD -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

####################
## FILTRE EXTERNE ##
####################

# IP à bannir du fichier "banlist.txt
##cat banip.txt | while read line ; do iptables -A INPUT -s $line -j DROP ; done

# Liste des IP à interdire avec ipset
ipset -q flush ipsum
ipset -q create ipsum hash:net
for ip in $(curl --compressed https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt 2>/dev/null | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1); do ipset add ipsum $ip; done
iptables -I INPUT -m set --match-set ipsum src -j DROP
