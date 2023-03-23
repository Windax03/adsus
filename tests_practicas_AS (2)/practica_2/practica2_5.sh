#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

echo -n "Introduzca el nombre de un directorio: "
read directorio

num_dir=$( ls -l "$directorio" | grep ^d | wc -l )  #Obtenemos el número de directorios dentro del directorio especificado
num_fil=$( ls -l "$directorio" | grep ^- | wc -l )  #Obtenemos el número de ficheros dentro del directorio especificado


if test -d "$directorio"  #Si el directorio indicado existe, se muestran los ficheros y directorios que contiene
then
    echo "El numero de ficheros y directorios en "$directorio" es de $num_fil y $num_dir, respectivamente"  
else
    echo "$directorio no es un directorio"
fi
