#!/bin/bash

if [ "$UID" -ne 0 ]
then
    echo "El script necesita privilegios de admin"
    exit 1
fi

# Limpiamos reglas existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Politicas por defecto
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Reglas para permitir tráfico local
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i enp0s9 -j ACCEPT
iptables -A INPUT -i enp0s10 -j ACCEPT

# Permitir tráfico relacionado y establecido
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permitir a debianX hacer ping entre ellas
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT

# Bloquear ping desde el Host
iptables -A INPUT -p icmp --icmp-type echo-request -i enp0s8 -j DROP

# Permitir SSH desde cualquier origen a debian5
iptables -A FORWARD -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT

# Permitir HTTP desde el Host a debian1
iptables -A INPUT -p tcp --dport 80 -s 192.168.56.1 -j ACCEPT

# Permitir acceso a Internet para debianX
iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s3 -j ACCEPT

# Configurar NAT para acceso a Internet
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Guardar reglas iptables
iptables-save > /etc/iptables/rules.v4
