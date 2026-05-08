#!/bin/bash 
#Script para hacer los symlinks y dar permisos de ejecucion 
if [ -z "$1" ]; then 
    echo ""
    exit 1   
fi 

archivo="$1"

if [ ! -f "$archivo" ]; then 
    echo "El archivo no existe " 
    exit 1 
fi 

ruta=$(realpath "$archivo")
nombre=$(basename "$archivo" .sh)

echo "Instalando: $nombre"
echo "==================="

chmod +x "$ruta"

sudo ln -sf "$ruta" "/usr/bin/$nombre"
echo "Instalado con el nombre: $nombre "