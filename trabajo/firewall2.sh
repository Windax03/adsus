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

# Redirección de peticiones desde el NAT al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Redirección de peticiones desde el host al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Reglas para permitir tráfico local y tráfico relacionado con conexiones existentes
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permite el acceso a ssh y http (para el servidor web)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Permite las respuestas de conexiones existentes (incluyendo pings) a ser reenviadas
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permite el tráfico interno entre las subredes internas
iptables -A FORWARD -i enp0s9 -o enp0s10 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s9 -j ACCEPT

# Permite el tráfico de las subredes internas a Internet y al Host
iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT

# Habilita el NAT para que todas las máquinas debianX puedan acceder a Internet y a la red Host-Only usando la IP pública de debian1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Permite las conexiones a debian2 (servidor web) y a debian5 (servidor ssh) desde la red Host-Only y desde la red interna 2
iptables -A FORWARD -i enp0s8 -p tcp --dport 80 -d 192.168.30.2 -j ACCEPT
iptables -A FORWARD -i enp0s8 -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -i enp0s9 -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -i enp0s10 -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT

# Permite el ping entre las máquinas Debian, pero no desde el Host
iptables -A INPUT -i enp0s9 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s10 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s8 -p icmp --icmp-type echo-request -j DROP

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4
