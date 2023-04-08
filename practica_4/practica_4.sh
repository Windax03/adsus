#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

if [ "$UID" -ne 0 ]
then
        echo "Este script necesita privilegios de administracion"
        exit 1
fi

if [ $# -ne 2 ]
then
        echo "Numero incorrecto de parametros"
else
        if [ "$1" = "-a" ]
        then
                while IFS=, read -r user pass fullname
                do
                        if [ -z "$user" -o -z "$pass" -o -z "$fullname" ]
                        then
                                echo "Campo invalido"
                                exit 2
                        fi
                        useradd -c "$fullname" "$user" -m -k /etc/skel -U -K UID_MIN=1815 &>/dev/null
                        if [ $? -ne 0 ]
                        then
                                echo "El usuario $user ya existe"
                        else
                                echo "$user:$pass" | chpasswd
                                passwd -x 30 $user &>/dev/null
                                usermod -aG 'sudo' $user
                                echo "$fullname ha sido creado"
                        fi
                done < $2
        elif [ "$1" = "-s" ]
        then
                if [ ! -d /extra/backup ]
                then
                        mkdir -p /extra/backup
                fi
                while IFS=, read -r user pass fullname
                do
                        dir=$(getent passwd "$user" | cut -d: -f6)
                        tar -cf /extra/backup/$user.tar "$dir" &>/dev/null
                        if [ $? -eq 0 ]
                        then
                                userdel -fr "$user" &>/dev/null
                        fi
                done<$2
        else
                echo "Opcion invalida">&2
                exit 1
        fi
fi
