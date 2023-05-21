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

# Acceso a redes internas
iptables -t nat -A POSTROUTING -s 192.168.30.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.31.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.32.0/24 -o enp0s3 -j MASQUERADE

# Reglas para permitir tráfico local y tráfico relacionado con conexiones existentes
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permitir ping entre las máquinas Debian, pero no desde el Host
iptables -A INPUT -i enp0s9 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s10 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s8 -p icmp --icmp-type echo-request -j DROP

# Todo que se envia fuera de la extranet se le envia la Ip de Debian 1
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to 192.168.56.2
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.2

# Redirección de peticiones desde NAT
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Redirección de peticiones desde host
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Paso de trafico hacia extranet
iptables -A FORWARD -i enp0s3 -p all -j ACCEPT
iptables -A FORWARD -i enp0s8 -p all -j ACCEPT

# Se permite el envio hacia la red interna 1 y 2
iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -i enp0s10 -p all -j ACCEPT

# Se acepta el trafico dirigido al servidor web y ssh
iptables -A FORWARD -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -p tcp --dport 80 -d 192.168.30.2 -j ACCEPT

# Permite que entre todo el tráfico
iptables -A INPUT -i enp0s9 -p all -j ACCEPT
iptables -A INPUT -i enp0s10 -p all -j ACCEPT

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4
