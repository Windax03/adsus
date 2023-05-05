# Memoria Practica 5

Para la realización de la practica se usara las maquinas configuradas de la practica 4.

## Parte I

Se añade un nuevo disco, para ello se accede a la configuracion de la maquina y en el apartado de almacenamiento creamos un nuevo disco duro en el controlador SATA de 2 GB.

Se instala parted mediante el comando apt install parted y mediante parted -l ubicamos los discos.
Se crea una tabla de particiones mediante parted /dev/sdb mklabel gpt y posteriormete se usa el comando parted /dev/sdb mkpart p1 ext3 1MB 1024MB y parted /dev/sdb mkpart p2 ext4 1024MB 2048MB, para generar las particiones.

Para el correcto funcionamiento vamos a mirar si las particiones estan alineadas mediante el comando parted /dev/sdb align-check optimal, una vez realizada la comprobación se usa el comando mkfs -t ext3 /dev/sdb1 y mkfs -t ext4 /dev/sdb2, para crear el sistema de ficheros.

Luego se montan mediante el uso del comando mount -t ext3 /dev/sdb1 /media y mount -t ext4 /dev/sdb2 /var, para verificar que estan montados se utiliza el comando cat /etc/mtab | grep "/dev/sdb" , el cual mostrara las dos particiones montadas.

Es necesario añadir las lineas mostradas con el comando anterior en el archivo /etc/fstab , para actualizar su contenido con la nueva informacion de los discos particionados. Para comprobar que el sistema pierde información de estos discos montados, se reinicia el sistema y se utiliza el comando cat /etc/mtab | grep "/dev/sdb", para observar que sigue igual, o utilizar el comando lsblk para ver que las particiones siguen montadas.

## Parte II

Scrip1:
Para la parte 2 de la practica se ha realizado un script el cual se limita a ejecutar los comandos expuestos en el guion ssh -n as@$1 "sudo sfdisk -s", ssh -n as@$1 "sudo sfdisk -l | tail -n 3" y ssh -n as@$1 "df -hT" donde $1 es la ip que se pasa como parametro al script, ya que este script no se lanza sin el parametro, este script se lanza mediante el comando: ./practica5_parte2.sh 192.168.56.11

Para mostrar la salida que realmente nos interesa usamos sfdisk –l junto a tail para que solo nos enseñe las tres ultimas lineas.

## Parte III

Para utilizar lvm, lo instalamos mediante el comando sudo apt install lvm2 y se comprueba que esta instalado mediante systemctl list-units | grep 'lvm2', con lsblk comprobamos donde esta instalado el disco nuevo, en este caso en el fichero /dev/sdc, posteriormente se usa el
comando sudo fdisk /dev/sdc que abre el entorno fdisk, a continuación se realiza lo siguiente:

Orden: n
Tipo de particion: p
Número de partición: 1
Con esto se crea la nueva particion, pero todavia no hemos cambiado el tipo para ello:

Orden: t
Codigo hexadecimal: 8e

Se escribe la tabla en el disco y salimos del entorno fdisk con w

sudo parted /dev/sdc set 1 lvm on
Se usa este comando a continuacion para configurar la partición existente para ser utilizada como un volumen físico para LVM.

Scrip2:
Posteriormente hemos creado el script practica5_parte3_vg, antes de ejecutarlo debemos crear el nuevo grupo de volumen mediante el comando sudo vgcreate vg_p5 /dev/sdc1, una vez creado comprobamos que se ha creado el volumen usando el comando sudo vgdisplay el cual muestra los grupos de volumenes del sistema.
Es necesario desmontar las particiones antes de añadirlas al VG porque LVM requiere que los PVs no estén montados en el sistema(sudo umount -l /media y sudo umount -l /var) , una vez hecho todo esto el script se ejecutara de la forma sudo ./practica5_parte3_vg.sh sdb1 sdb2.

Scrip3:
Despues se ha creado por ultimo el script script practica5_parte3_lv.sh, el cual se ejecuta de la forma sudo ./script practica5_parte3_lv.sh volumen.txt, siendo volumen.txt un archivo en el cual se especifican los parametros descritos en el guion (nombreGrupoVolumen,nombreVolumenLogico,tamaño,tipoSistemaFicheros,directorioMontaje), en caso de no existir el volumen logico lo crea y si este ya existia lo agranda si se desea.
