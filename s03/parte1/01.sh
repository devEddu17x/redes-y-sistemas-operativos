#!/bin/bash
rm informe_errores.txt
touch informe_errores.txt
ARCHIVOS=$(ls /var/log | grep ".log")
echo "Listar todos los archivos con extensión .log del directorio /var/log"
echo "$ARCHIVOS"

for archivo in $ARCHIVOS; do
    if grep -q "error" "/var/log/$archivo"; then
        echo "Archivo con error: $archivo"
        tail -n 20 /var/log/$archivo
        echo "Archivo con error: $archivo" >> informe_errores.txt
        tail -n 20 /var/log/$archivo >> informe_errores.txt
    fi
done