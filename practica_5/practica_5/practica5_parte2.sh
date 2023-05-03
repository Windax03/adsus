#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

if [ $# -ne 1]
then
    echo "El script necesita una Ip como parametro"
    exit 1
fi

ssh -n as@$1
if [ $? -eq 0 ]
then

    ssh -n as@$IP "sfdisk –s"
    ssh -n as@$IP "sfdisk –l"
    ssh -n as@$IP "df -hT"

else
    echo "$1 no es accesible"
    exit 1
fi
