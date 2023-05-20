#!/bin/bash

# Comprobar si el script se ejecuta como root
if [ "$UID" -ne 0 ]; then
    echo "El script necesita privilegios de administrador."
    exit 1
fi

# Limpiar todas las reglas existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Establecer políticas predeterminadas
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# Permitir tráfico local y tráfico relacionado con conexiones existentes
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Permitir el acceso a ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir a las máquinas debian acceso a Internet
iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s3 -j ACCEPT

# Permitir respuestas a conexiones ya establecidas
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Habilitar NAT para que las máquinas debian puedan usar la IP pública de debian1 para acceder a Internet
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Permite que debian1 responda a los pings generados en la intranet, pero no a los generados desde la máquina Host
iptables -A INPUT -i enp0s9 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i enp0s10 -p icmp --icmp-type echo-request -j ACCEPT

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4