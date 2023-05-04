#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

OLDIFS=$IFS
IFS=','
while read nombreGrupoVolumen nombreVolumenLogico tamagno tipoSistemaFicheros directorioMontaje
do
    vdir=$(lvdisplay "$nombreGrupoVolumen/$nombreVolumenLogico" -Co "lv_path" | grep "$nombreGrupoVolumen/$nombreVolumenLogico" | tr -d '[[:space:]]') &> /dev/null
    if [ -n "$vdir" ]
    then
        echo "El volumen introducido ya existe,ahora se ampliara"
        lvextend -L$tamagno $vdir
        resize2fs $vdir
    else
        echo "El volumen introducido no existe,ahora se creara"
        lvcreate -L $tamagno -n $nombreVolumenLogico $nombreGrupoVolumen
        if [ $? -eq 0 ]
        then
            if [ ! -d $directorioMontaje ]
            then
                mkdir -p $directorioMontaje
            fi
            vdir=$(lvdisplay "$nombreGrupoVolumen/$nombreVolumenLogico" -Co "lv_path" | grep "$nombreGrupoVolumen/$nombreVolumenLogico" | tr -d '[[:space:]]')
            cat /etc/mtab | grep "/dev/"$directorioMontaje""  >> /etc/fstab
            mkfs.$tipoSistemaFicheros $vdir
            mount $vdir $directorioMontaje
        fi
    fi
    break
done
IFS=$OLDIFS