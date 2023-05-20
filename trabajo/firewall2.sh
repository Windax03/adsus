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
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# Reglas para permitir tráfico local y tráfico relacionado con conexiones existentes
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permite el acceso a ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permite el tráfico interno entre las subredes internas
iptables -A FORWARD -i enp0s9 -o enp0s10 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s9 -j ACCEPT

# Permite el tráfico de las subredes internas a Internet y al Host
iptables -A FORWARD -i enp0s9 -o enp0s3 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s9 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s3 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s10 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Habilita el NAT para que todas las máquinas debianX puedan acceder a Internet y a la red Host-Only usando la IP pública de debian1
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4
