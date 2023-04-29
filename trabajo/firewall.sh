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
iptables -t nat -A PREROUTING -i enp0s8 -j DNAT --to 192.168.56.1
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.1

# Redirección de peticiones al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.30.2:80
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.2:22

# Permite el paso de todo el tráfico de intranet
iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -i enp0s10 -p all -j ACCEPT

# Se permite el tráfico hacia debian5 por el puerto 22 (ssh) 
# y hacia debian2 por los puertos 80(http)
iptables -A FORWARD -d 192.168.32.2 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -d 192.168.30.2 -p tcp --dport 80 -j ACCEPT

# Permite que entre todo el tráfico de intranet y la respuesta del host a los pings
iptables -A INPUT -i enp0s9 -p all -j ACCEPT
iptables -A INPUT -i enp0s10 -p all -j ACCEPT
iptables -A INPUT -i lo -p all -j ACCEPT

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4