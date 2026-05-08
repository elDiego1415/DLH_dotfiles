#!/bin/bash

FECHA=$(date)
NOTAS_DIR="$HOME/notas"

#creas archivo con las notas 
#hacer git push de las notas 

cd "$NOTAS_DIR" || {
	echo "No se pudo acceder al directorio"
	exit 1
}

git add .
git commit -m "Backup notas $FECHA"
git push 
