# Memoria Practica 5

Para la realización de la practica se usara las maquinas configuradas de la practica 4, se instala lvm2 mediante el comando
sudo apt-get install lvm2, despues se comprueba con el comando systemctl list-units | grep 'lvm2' para buscar el servicio
si el comando anterior muestra algo por pantalla el servicio estará activo.

## Parte I

Se añade un nuevo disco para ello se accede a la configuracion de la maquina y en el apartado de almacenamiento creamos un nuevo disco duro SATA
de 40 MB.

Instalamos parted mediante el comando apt install parted, mediante parted -l mostramos los discos y donde se localizan para posteriormente usarlo
para crear una partición mediante el comando parted /dev/sdb mklabel gpt, posteriormete se usa el comando parted /dev/sdb mkpart p1 ext3 1MB 1024MB y para la otra partición usamos parted /dev/sdb mkpart p2 ext4 1024MB 2048MB.

Para el correcto funcionamiento vamos a mirar si las particiones estan alineadas mediante el comando parted /dev/sdb align-check optimal, una vez comprobado su alineamiento se usa el comando mkfs -t ext3 /dev/sdb1 para crear el sistema de ficheros y mkfs -t ext4 /dev/sdb2

Se montan mediante el uso del comando mount -t ext3 /dev/sdb1 /media y mount -t ext4 /dev/sdb2 /var, para verificar que estan montados se utiliza el comando
cat /etc/mtab | grep "/dev/sdb" , el cual mostrara las dos particiones montadas.

Es necesario añadir las lineas mostradas con el comando anterior en el archivo /etc/fstab , para actualizar su contenido con la nueva informacion de los discos particionados. Para comprobar que el sistema no ha perdido la información de estos discos montados se utiliza el comando cat /etc/mtab | grep "/dev/sdb", con el cual mostraremos los discos montados actualmente, o utilizar el comando lsblk para listar los dispositivos de bloque comprobando que esta todo igual que antes de reiniciar.

## Parte II

Para la parte 2 de la practica se ha realizado un script el cual se limita a ejecutar los comandos expuestos en el guion ssh -n as@$1 "sfdisk –s", ssh -n as@$1 "sfdisk –l | tail -n 3" y ssh -n as@$1 "df -hT" donde $1 es la ip que se pasa como parametro al script, ya que este script no se lanza sin el parametro.

Para mostrar la salida que realmente nos interesa usamos sfdisk –l junto a tail para que solo nos enseñe las tres ultimas lineas

## Parte III
