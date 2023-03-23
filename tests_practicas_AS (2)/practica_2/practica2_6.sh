#!/bin/bash
#845647, Leris Lacort, Jorge, M, 3, A
#844759, Villanueva Agudo, Ángel, M, 3, A

contador=0

directorio=$(stat -c %n,%Y ~/bin??? 2> /dev/null | sort -t ',' -k 2 | head -n 1 | cut -d ',' -f 1)   # Miramos el nombre del directorio más reciente en la carpeta raiz
if [ "$directorio" = "" ]   # Si no hay directorio más reciente
then
    directorio=$(mktemp -d ~/binXXX)                #Creamos el directorio temporal
    echo "Se ha creado el directorio $directorio"
fi

echo "Directorio destino de copia: $directorio"     #Mostramos el destino
for contenido in $ls    # Iteramos por el directorio actual para ver los archivos
do
    if test -f "$contenido" -a -x "$contenido"  # Si existe el archivo, es regular y es ejecutable
    then
        cp "$contenido" "$directorio"           
        echo "./$contenido ha sido copiado a $directorio"  # Copiamos el archivo al nuevo directorio
        contador=$(contador+1) # Aumentamos el numero de archivos copiados
    fi 
done

if [ "$contador" = 0 ]  # Si el contador es nulo
then
    echo "No se ha copiado ningun archivo"  # No se copio ningun archivo
else
    echo "Se han copiado $contador archivos" # Se copiaron contador archivos
fi

