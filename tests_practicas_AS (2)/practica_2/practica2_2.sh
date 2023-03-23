#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A


for file in "$@"    # Iteramos en todos los argumentos introducidos
do
    if test -f "$file"  #Comprobamos si existe
    then
        more "$file"   # Mostramos el fichero
    else
        echo "$file no es un fichero"  # En caso contrario no es un fichero
    fi

done