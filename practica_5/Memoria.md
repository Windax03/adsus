# Memoria Practica 5

Para la realización de la practica se usara las maquinas configuradas de la practica 4, se instala lvm2 mediante el comando
sudo apt-get install lvm2, despues se comprueba con el comando systemctl list-units | grep 'lvm2' para buscar el servicio
si el comando anterior muestra algo por pantalla el servicio estará activo.

## Parte I

Se añade un nuevo disco para ello se accede a la configuracion de la maquina y en el apartado de almacenamiento creamos un nuevo disco duro SATA
de 40 MB.

Instalamos parted mediante el comando sudo apt install parted, mediante sudo parted -l mostramos los discos y donde se localizan para posteriormente usarlo
para crear una partición

## Parte II

## Parte III
