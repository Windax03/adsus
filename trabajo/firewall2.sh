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

# Reglas para permitir tráfico local y tráfico relacionado con conexiones existentes
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permite el acceso a ssh y http (para el servidor web)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Permitir el tráfico entre las máquinas debianX y debian1
iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT

# Permitir el tráfico de las máquinas debianX a Internet
iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s3 -j ACCEPT

# Habilitar el NAT para las máquinas debianX
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Permitir el acceso desde cualquier máquina a debian5 mediante ssh
iptables -A FORWARD -i enp0s8 -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -i enp0s9 -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -i enp0s10 -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT

# Redirección de ssh desde el Host al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22

# Permitir el tráfico ICMP desde las máquinas debianX al Host pero bloquear el inverso
iptables -A FORWARD -i enp0s8 -o enp0s9 -p icmp --icmp-type echo-request -j DROP
iptables -A FORWARD -i enp0s8 -o enp0s10 -p icmp --icmp-type echo-request -j DROP
iptables -A FORWARD -i enp0s9 -o enp0s8 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s8 -p icmp --icmp-type echo-request -j ACCEPT

# Permitir tráfico entre las máquinas debianX
iptables -A FORWARD -i enp0s9 -o enp0s10 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s9 -j ACCEPT

# Guardar reglas
iptables-save > /etc/iptables/rules.v4
