#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

# Comprobacion de usuario y parametros
if [ "$UID" -ne 0 ]
then

    echo "Este script necesita privilegios de administrador al usar comandos como lvdisplay"
    exit 1
elif [ $# -ne 1 ]
then

    echo "Este script necesita un fichero como parametro"
    exit 1
fi

OldIFS=$IFS
IFS=','
while read nombreGrupoVolumen nombreVolumenLogico tamagno tipoSistemaFicheros directorioMontaje
do
    # Asignamos a vldir el directorio del volumen
    vldir=$(echo "/dev/$nombreGrupoVolumen/$nombreVolumenLogico")
    # Miramos si hay coincidencia
    lvdisplay "$nombreGrupoVolumen/$nombreVolumenLogico" | grep ""$vldir"" &> /dev/null
    # Si el comando anterior se ejecuta con exite el volumen existe en el sistema
    if [ $? -eq 0 ]
    then
        
        echo "El volumen logico existe en el sistema, a continuacion se procede a ampliarlo"
        # Reducimos el volumen logico
        lvextend -L$tamagno $vldir
        # Agrandar el sistema de ficheros
        resize2fs $vldir
    else
        echo "El volumen introducido no existe,ahora se creara"
        # Crear un volumen logico
        lvcreate -L $tamagno -n $nombreVolumenLogico $nombreGrupoVolumen
        # Comprobamos que el volumen logico se ha podido crear sin problemas
        if [ $? -eq 0 ]
        then
            # Si no existe el directorio donde montaremos el volumen logico lo creamos
            if [ ! -d $directorioMontaje ]
            then
                # Se crea el directorio de montaje
                mkdir $directorioMontaje
            fi

            echo -e "$vldir\t$directorioMontaje\t$tipoSistemaFicheros\tdefaults 0 0" >> /etc/fstab
            # Creamos el sistema de archivos del volumen logico
            mkfs -t $tipoSistemaFicheros $vldir
            # Se monta el volumen logico con las especificaciones del tipo, ruta y donde se monta
            mount -t $tipoSistemaFicheros $vldir $directorioMontaje
        fi
    fi

done < $1
IFS=$OldIFS