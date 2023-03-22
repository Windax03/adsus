#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

if [ "$(id -u)" -ne 0 ]
then 
  echo "Este script necesita privilegios de administracion"
  exit 1
fi

if [ $# -ne 2 ]
then
  echo "Numero incorrecto de parametros"
  exit 1
fi

while IFS=, read -r user pass fullname
do
  if [ "$1" = "-a" ]
  then
    if [ -z "$user" -o -z "$pass" -o -z "$fullname" ]
    then
      echo "Campo invalido"
      exit 2
    fi
    useradd -c "$fullname" "$user" -m -k /etc/skel -K UID_MIN=1815 -U &>/dev/null
    if [ $? -ne 0 ]
    then
      echo "El usuario $user ya existe"
    else
      echo "$user:$pass" | chpasswd "$user" &>/dev/null
      passwd -x 30 "$user" &>/dev/null
      usermod -aG "sudo" "$user" &/dev/null
      echo "$fullname ha sido creado"
    fi
  elif [ "$1" = "-s" ]
  then
    if [ ! -d /extra/backup ]
    then
      mkdir -p /extra/backup
    fi
    dir=$(getent passwd "$user" | cut -d: -f6)
    tar -cf "/extra/backup/$user".tar -C "$dir" &>/dev/null
    if [ $? -eq 0 ]
    then
      userdel -fr "$user" &>/dev/null
    fi
  else
    echo "Opcion invalida">&2
    exit 1
  fi
done < $2
