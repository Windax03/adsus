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
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Configuración de NAT para acceso a Internet
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Reglas para permitir tráfico local
iptables -A INPUT -i lo -j ACCEPT

# Reglas para permitir tráfico de red interna
iptables -A INPUT -i enp0s8 -j ACCEPT
iptables -A INPUT -i enp0s9 -j ACCEPT
iptables -A INPUT -i enp0s10 -j ACCEPT

# Permitir tráfico de red relacionado y existente
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Bloquear ping desde el host
iptables -A INPUT -p icmp --icmp-type echo-request -i enp0s3 -j DROP

# Redireccionar tráfico SSH y HTTP a debian5 y debian2 respectivamente
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 22 -j DNAT --to-destination 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to-destination 192.168.30.2:80

# Guardar reglas iptables
iptables-save > /etc/iptables/rules.v4
