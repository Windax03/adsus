#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

echo -n "Introduzca el nombre del fichero: " 
read file

if test -f "$file"
then
    echo -n "Los permisos del archivo $file son: "
    
    if test -r "$file"      # Comprobamos si el archivo tiene permiso de lectura
    then
        echo -n "r"
    else
        echo -n "-"
    fi

    if test -w "$file"      # Comprobamos si el archivo tiene permiso de escritura
    then
        echo -n "w"
    else
        echo -n "-"
    fi

    if test -x "$file"      # Comprobamos si el archivo tiene permiso de ejecucción
    then
        echo "x"
    else
        echo "-"
    fi

else
    echo "$file no existe"    # Si no existe el archivo
fi

