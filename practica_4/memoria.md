# Memoria ADSIS

## Parte 1: Preparación de las máquinas de VirtualBox

-Primero de todo se crea en virtualBox un red de tipo "Host-Only-Nework" (IPv4 Address: 192.168.56.1).
-A continuación se han creado dos máquinas debian para la realización de la pŕactica y nustro propio ordenador como host.
-En estas dos máquinas se ha modificado el fichero sudoers añadiendo la siguiente fila: "as ALL=(ALL) NOPASSWD:ALL,
con el fin de que no se necesite poner la contraseña al usar sudo
-Finalmente se han modificado los adaptadores de red de las dos máquinas:
El adaptador 1 ya estaba como se quería (activo y conectado a "NAT")
El adaptador 2, que se ha activado y conectado a "Adaptador sólo-anfitriçon"

## Parte 2. Configuración de las máquinas virtuales

Para la configuración de las maquinas virtuales se ha de modificar el fichero "/etc/network/interfaces" al cual se le tiene que
añadir la información siguiente:
-auto enp0s8
-iface enp0s8 inet static
-address 192.168.56.11
-netmask 255.255.255.0

Posteriomente se usa el comando ping para comprobar que el host y las maquinas se pueden comunicar entre si sin ningun tipo de problema,
después se configura el servidor ssh, para ello modificamos el archivo "/etc/ssh/sshd_config" descomentando la linea "PermitRootLogin no"

Para finalizar simplemente comprobamos si los comandos ssh "as@192.168.56.11" y "ssh as@192.168.56.11" nos permiten acceder a las maquinas.

## Parte 3. Preparación de la infraestructura de autenticación

En el host se genera la claves "ed25519", que se almacenan en un fichero de nombre "id_as_ed25519" ubicado en el directorio "as" dentro
del home del host mediante el comando "ssh-keygen -t ed25519 -f .ssh/id_as_ed25519", para llevar estas claves a las maquinas as-1 y as-2
se utiliza el comando "ssh-copy-id -i .ssh/id_as_ed25519 as@192.168.56.11" y "ssh-copy-id -i .ssh/id_as_ed25519 as@192.168.56.12",
esto nos permitira acceder a estas sin usar la contraseña.

## Parte 4. Creación de usuarios

Por ultimo se ha usado el script que teniamos de la practica 3, realizando algunas pequeñas modificaciones a este, se añade como parametro un fichero maquinas.txt
que contiene las ips de las maquinas y los comandos que se ejecutan se tienen que ejecutar en las maquinas virtuales por ello se añade la linea ssh -n as@$IP, delante de cada comando.
