!#bin/bash
awk -F ':' '{print $1, $7}' /etc/passwd | sort > usuarios.txt | echo "Cantidad de usuarios: $(wc -l 01.sh)"