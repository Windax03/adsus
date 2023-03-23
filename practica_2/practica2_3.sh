#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

if [ $# = 1 ]
then
    if test -f "$1"             # Si existe el archivo y es común
    then
        chmod u+x "$1"          # Convertimos en ejecutable para el user y para el grupo
        chmod g+x "$1"
        stat -c '%A' "$1"       # Mostramos el modo final
    else
        echo "$1 no existe"
    fi
else
    echo "Sintaxis: practica2_3.sh <nombre_archivo>"   # No se ha introducido un nombre de archivo
fi

