#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

echo -n "Introduzca una tecla: "
read tecla

tecla=$( echo "$tecla" | cut -c1 )

#comprobamos si es numero
if [[ $tecla  = [0-9] ]]
then
    echo "$tecla es un numero"

    #comprobamos si es letra
elif [[ $tecla  = [a-zA-Z] ]]
then
    echo "$tecla es una letra"

    #comprobamos si es caracter especial
else
    echo "$tecla es un caracter especial"
fi