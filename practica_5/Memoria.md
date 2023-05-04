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

Para mostrar la salida que realmente nos interesa usamos sfdisk –l junto a tail para que solo nos enseñe las tres ultimas lineas.

## Parte III

Para utilizar lvm, lo instalamos mediante el comando sudo apt install lvm2 y se comprueba que esta instalado mediante systemctl list-units | grep 'lvm2', para comprobar que el servicio esta instalado, con lsblk comprobamos donde esta instalado el disco nuevo, en este caso en el fichero /dev/sdc, posteriormente se usa el
comando sudo fdisk /dev/sdc mostrando lo siguiente
Orden (m para obtener ayuda): n
Tipo de particion
p primaria
e extendida
Seleccionar (valor predeterminado: p): p
Número de partición: 1
Primer sector: valor predeterminado
Ultimo sector: valor predeterminado

Con esto se crea la nueva particion, pero todavia no hemos cambiado el tipo para ello:
Orden (m para obtener ayuda): t
Se ha seleccionado la particion 1
Codigo hexadecimal: 8e
Se ha cambiado el tipo de la particion "Linux" a "Linux LVM"

Orden (m para obtener ayuda): w
Se escribe la tabla en el disco y salimos del entorno fdisk

sudo parted /dev/sdc set 1 lvm on
Se usa este comando a continuacion para configurar la partición existente para ser utilizada como un volumen físico para LVM.

Posteriormente hemos creado el script practica5_parte3_vg, antes de ejecutarlo debemos crear el nuevo grupo de volumen mediante el comando sudo vgcreate vg_p5 /dev/sdc1, una vez creado comprobamos que se ha creado el volumen usando el comando sudo vgdisplay el cual muestra los grupos de volumenes del sistema, es necesario desmontar las particiones antes de añadirlas al VG porque LVM requiere que los PVs no estén montados en el sistema, una vez hecho todo esto el script se ejecutara de la forma sudo ./practica5_parte3_vg.sh sdb1 sdb2.

A continuación se procede a desmontar los discos del sistema mediante los comandos sudo umount -l /media y sudo umount -l /var para desmontar los discos actuales, poniendo -l para que se pueda desmontar los discos en segundo plano y permitir que los procesos accedan a el. Se descomentan las lineas de los discos en el fichero /etc/fstab y se ha reiniciado la maquina para ejecutar el script y añadirlo al grupo de volumen, mediante el comando sudo pvdisplay muestra los tres volumenes que se han creado.

Para elimiminar los volumenes creados hay que poner sudo vgreduce vg_p5 /dev/sdb1, posteriormente sudo pvremove /dev/sdb1, si se desea volver a montar los discos habra que crear el sistema de archivos tambien mediante mkfs.

sudo lvremove /dev/mi_grupo_volumenes_mi_volumen
