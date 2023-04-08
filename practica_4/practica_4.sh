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
                while read -r IP
                do
                        ssh -n as@$IP
                        if [ $? -eq 0 ]
                        then
                                while IFS=, read -r user pass fullname
                                do
           
                                        if [ -z "$user" -o -z "$pass" -o -z "$fullname" ]
                                        then
                                                echo "Campo invalido"
                                                exit 2
                                        fi
                                        ssh -n as@$IP "useradd -c "$fullname" "$user" -m -k /etc/skel -U -K UID_MIN=1815 &>/dev/null"
                                        if [ $? -ne 0 ]
                                        then
                                                ssh -n as@$IP "echo "El usuario $user ya existe""
                                        else
                                                ssh -n as@$IP "echo "$user:$pass" | chpasswd"
                                                ssh -n as@$IP "passwd -x 30 $user &>/dev/null"
                                                ssh -n as@$IP "usermod -aG 'sudo' $user"
                                                ssh -n as@$IP "echo "$fullname ha sido creado""
                                        fi
                                done < $1
                        else
                                echo "$IP no es accesible"
                        fi
                done < $2
        elif [ "$1" = "-s" ]
        then
                while read -r IP
                do
                        ssh -n as@$IP
                        if [ $? -eq 0 ]
                        then
                                ssh -n as@$IP "[ ! -d /extra/backup ] && mkdir -p /extra/backup"
                                while IFS=, read -r user pass fullname
                                do
                                        dir=$(ssh -n as@$IP getent passwd "$user" | cut -d: -f6)
                                        ssh -n as@$IP "tar -cf /extra/backup/$user.tar "$dir" &>/dev/null"
                                        if [ $? -eq 0 ]
                                        then
                                                ssh -n as@$IP "userdel -fr "$user" &>/dev/null"
                                        fi
                                done < $1
                        else
                                echo "$IP no es accesible"
                        fi
                done < $2
        else
                echo "Opcion invalida">&2
                exit 1
        fi
fi
