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

# Reglas para permitir tráfico local y tráfico relacionado con conexiones existentes
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permitir ping entre las máquinas Debian, pero no desde el Host
iptables -A INPUT -i enp0s9 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s10 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s8 -p icmp --icmp-type echo-request -j DROP

# Permite las respuestas de conexiones existentes (incluyendo pings) a ser reenviadas
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permitir tráfico de las subredes internas a Internet y al Host
iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT

# Se permite el tráfico hacia debian5 por el puerto 22 (ssh) y hacia debian2 por el puerto 80
iptables -A FORWARD -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -p tcp --dport 80 -d 192.168.30.2 -j ACCEPT

# Redirección de peticiones desde el NAT al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Redirección de peticiones desde el host al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# INTERNET
iptables -A INPUT -i enp0s3 -m state --state ESTABLISHED,RELATED -j ACCEPT  # Permitimos la vuelta del flujo de trafico al sistema intranet.
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to 192.168.56.2          # Direccion IP origen de paquetes de NAT = direccion publica del firewall.
iptables -A INPUT -i enp0s3 -j DROP                                         # Restringimos el resto de trafico que no nos interesa.

iptables -A FORWARD -i enp0s3 -o enp0s8 -j DROP                             # Restringimos el flujo de paquetes desde NAT a Host-Only Network.
iptables -A FORWARD -i enp0s8 -o enp0s3 -j DROP                             # Restringimos el flujo de paquetes desde Host-Only Network a NAT.

# Habilita el NAT para que todas las máquinas debianX puedan acceder a Internet y a la red Host-Only usando la IP pública de debian1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4