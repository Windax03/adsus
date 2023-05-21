#!/bin/bash
# Script de configuración de iptables
#
if [ $EUID -ne 0 ];
then 
    echo -e "requieres de permisos de administracion o ser root\n\n"
    exit 1
fi

if [ ! -f /etc/iptables/rules.v4 ]; then iptables-save > /etc/iptables/rules.v4; fi
if [ ! -f /etc/iptables/rules.v4.original ]; then cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.original; fi

# LIMPIEZA DE REGLAS EN IPTABLES
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# POLITICAS POR DEFECTO
iptables -P INPUT DROP
iptables -P FORWARD DROP

# INTRANET
iptables -A OUTPUT -j ACCEPT                                                # Permitimos el flujo de paquetes de intranet a extranet.

# EXTRANET
# HOST-ONLY NETWORK
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport ssh -j DNAT --to 192.168.32.2         # Redireccionaramos conexion ssh entrante del host al servidor ssh de Debian5.
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.30.2          # Redireccionaramos conexion web entrante del host al servidor web Apache de Debian2.
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.2                          # Direccion IP origen de paquetes del Host = direccion publica del firewall.
iptables -A INPUT -i enp0s8 -s 192.168.56.0/24 -p icmp --icmp-type echo-request -j DROP     # Restringimos el envio de paquetes desde ping al sistema intranet.
iptables -A INPUT -i enp0s8 -j DROP                                                         # Restringimos el resto de trafico que no nos interesa.

# INTERNET
iptables -A INPUT -i enp0s3 -m state --state ESTABLISHED,RELATED -j ACCEPT  # Permitimos la vuelta del flujo de trafico al sistema intranet.
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to 192.168.56.2          # Direccion IP origen de paquetes de NAT = direccion publica del firewall.
iptables -A INPUT -i enp0s3 -j DROP                                         # Restringimos el resto de trafico que no nos interesa.

iptables -A FORWARD -i enp0s3 -o enp0s8 -j DROP                             # Restringimos el flujo de paquetes desde NAT a Host-Only Network.
iptables -A FORWARD -i enp0s8 -o enp0s3 -j DROP                             # Restringimos el flujo de paquetes desde Host-Only Network a NAT.

#iptables -L                                                                # Lista de reglas del firewall.

rm /etc/iptables/rules.v4
iptables-save > /etc/iptables/rules.v4