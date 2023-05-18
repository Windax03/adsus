# LIMPIEZA DE REGLAS EN IPTABLES
iptables -F

# Políticas por defecto
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Se da acceso a las tres redes internas
iptables -t nat -A POSTROUTING -s 192.168.30.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.31.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.32.0/24 -o enp0s3 -j MASQUERADE

# A todo lo que sale a la extranet se le proporciona la IP de debian1
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to 192.168.56.2
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.2

# Redirección de peticiones desde el NAT al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Redirección de peticiones desde el host al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80

# Se permite el paso del tráfico hacia la extranet (SSH y servidor web)
iptables -A FORWARD -i enp0s3 -p all -j ACCEPT
iptables -A FORWARD -i enp0s8 -p all -j ACCEPT

# Se permite todo el paso hacia red interna 1 y red interna 2
iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -i enp0s10 -p all -j ACCEPT

# Se permite el tráfico hacia debian5 por el puerto 22 (ssh) y hacia debian2 por el puerto 80
iptables -A FORWARD -p tcp --dport 22 -d 192.168.32.2 -j ACCEPT
iptables -A FORWARD -p tcp --dport 80 -d 192.168.30.2 -j ACCEPT

# Permite que entre todo el tráfico de intranet
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -i enp0s9 -p all -j ACCEPT
iptables -A INPUT -i enp0s10 -p all -j ACCEPT

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4
