#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

# Comprobamos que se han pasado al menos dos argumentos: el nombre del VG y uno o más nombres de particiones
if [ $# -lt 2 ]
then
    echo "Error: debe indicar el nombre del VG y uno o más nombres de particiones para añadir."
    exit 1
fi

# Comprobamos que se está ejecutando el script como superusuario
if [ "$EUID" -ne 0 ]
then
    echo "Error: este script debe ser ejecutado con permisos de superusuario."
    exit 1
fi

# Asignamos el primer argumento al nombre del VG
VG="$1"
shift

# Iteramos sobre los nombres de las particiones
for PARTITION_NAME in "$@"
do

    # Añadimos el volumen físico al VG
    vgextend "$VG" "/dev/$PARTITION_NAME"

    echo "La partición /dev/$PARTITION_NAME se ha añadido correctamente al VG $VG."
done

# Asignamos el nombre "vg_p5" al VG resultante
vgrename "$VG" vg_p5

# Mostramos la información del VG resultante
vgdisplay vg_p5
