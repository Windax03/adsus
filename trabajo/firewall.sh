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
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.32.1:22

# Permite el paso de todo el tráfico de intranet
#iptables -A FORWARD -i enp0s8 -p icmp --icmp-type 0 -j ACCEPT
#iptables -A FORWARD -i enp0s3 -p all -j ACCEPT
#Debe prohibir todo el tráfico desde la extranet a la intranet salvo el generado
#por las conexiones al servidor web en debian2 y al servidor ssh en debian5. Es
#decir, las páginas web del servidor deben ser accesibles desde la máquina
#Host, y se debe poder conectar vía ssh al servidor debian5 desde Host.
iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -i enp0s10 -p all -j ACCEPT

# Se permite el tráfico hacia debian5 por el puerto 22 (ssh) 
# y hacia debian2 por los puertos 80(http) y 443(https)
iptables -A FORWARD -d 192.168.32.2 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -d 192.168.30.2 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -d 192.168.30.2 -p tcp --dport 443 -j ACCEPT

# Permite que entre todo el tráfico de intranet y la respuesta del host a los pings
iptables -A INPUT -i enp0s8 -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -i enp0s3 -p all -j ACCEPT
iptables -A INPUT -i enp0s9 -p all -j ACCEPT
iptables -A INPUT -i enp0s10 -p all -j ACCEPT
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -i enp0s3 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i enp0s8 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4