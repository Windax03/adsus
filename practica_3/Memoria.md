# Memoria de la practica 3 AS
Autor: Jorge Leris Lacort
NIP: 845647
Autor: Ángel Villanueva Agudo
NIP: 844759

# Script de Bash para crear usuarios y eliminarlos

Este script de Bash tiene como objetivo crear y borrar usuarios además de realizar backups de sus directorios. Para ello, se han tomado una serie de decisiones de diseño y se han incluido varias validaciones para asegurar que el script funcione correctamente.

## Validación de privilegios de administración

Antes de comenzar con la ejecución del script, se valida si el usuario que lo está ejecutando tiene privilegios de administración. Para ello, se utiliza la variable $UID que contiene el ID del usuario que ha iniciado la sesión. Si $UID no es igual a 0, se muestra un mensaje indicando que se necesitan privilegios de administración para ejecutar el script y se finaliza la ejecución con código de salida 1.

## Validación del número de parámetros
El script espera recibir dos parámetros: la opción (-a o -s) y el archivo que contiene los datos de los usuarios. Si el número de parámetros recibidos es diferente a 2, se muestra un mensaje indicando que el número de parámetros es incorrecto.

## Creación de usuarios
Si la opción recibida es -a, se procede a crear los usuarios. Para ello, se lee el archivo que contiene los datos de los usuarios línea por línea y se separan los campos mediante la coma ,. Si alguno de los campos está vacío, se muestra un mensaje indicando que el campo es inválido y se finaliza la ejecución con código de salida 2.

Se utiliza el comando useradd para crear el usuario con el nombre de usuario, la descripción y el directorio de inicio especificados. Además, se establece una contraseña utilizando el comando chpasswd y se configura la caducidad de la contraseña mediante el comando passwd. Finalmente, se agrega al usuario al grupo sudo. Si el usuario ya existe, se muestra un mensaje indicando que el usuario ya existe.

## Eliminacion y Backup de directorios de usuario

Si la opción recibida es -s, se procede a realizar backups de los directorios de los usuarios especificados en el archivo. Primero, se verifica si el directorio /extra/backup existe. Si no existe, se crea el directorio.

Se lee el archivo que contiene los datos de los usuarios y se separan los campos mediante la coma ,. Se utiliza el comando getent para obtener la información del usuario y se extrae la ruta del directorio de inicio del usuario mediante el comando cut. A continuación, se utiliza el comando tar para crear un archivo .tar que contiene el contenido del directorio de inicio del usuario y se guarda en el directorio /extra/backup. Si la operación se realiza correctamente, se elimina el usuario y su directorio de inicio mediante el comando userdel.

## Opción inválida

Si la opción recibida no es -a ni -s, se muestra un mensaje indicando que la opción es inválida y se finaliza la ejecución con código de salida 1.
