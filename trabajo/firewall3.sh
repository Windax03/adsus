#!/bin/bash

# Limpiar todas las reglas existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Política por defecto: bloquear todo el tráfico
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Permitir tráfico ilimitado en la interfaz lo (localhost)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permitir tráfico entrante de la red local
iptables -A INPUT -i enp0s8 -j ACCEPT
iptables -A INPUT -i enp0s9 -j ACCEPT
iptables -A INPUT -i enp0s10 -j ACCEPT

# Permitir tráfico saliente a la red local
iptables -A OUTPUT -o enp0s8 -j ACCEPT
iptables -A OUTPUT -o enp0s9 -j ACCEPT
iptables -A OUTPUT -o enp0s10 -j ACCEPT

# Asumiendo que enp0s3 es la interfaz que tiene acceso a internet

# Permitir tráfico saliente a internet
iptables -A OUTPUT -o enp0s3 -j ACCEPT

# Permitir tráfico entrante relacionado o establecido
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Configurar NAT para las redes internas
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Registrar todo lo demás (paquetes bloqueados)
iptables -A INPUT -j LOG
iptables -A OUTPUT -j LOG
iptables -A FORWARD -j LOG
