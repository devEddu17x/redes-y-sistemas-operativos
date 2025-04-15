ARCHIVO_CSV="memoria_estado.csv"
read -p "Ingrese tiempo en minutos: " MINUTOS
read -p "Ingrese tiempo de espera en segundos: " TIEMPO_ESPERA
SEGUNDOS=$((MINUTOS * 60))
echo "Hora, MemoriaTotal, MemoriaUsada, MemoriaLibre, SwapTotal, SwapUsada" > $ARCHIVO_CSV
for ((i=1; i <= SEGUNDOS; i+=TIEMPO_ESPERA)); do
    HORA=$(date +"%H:%M:%S")
    #tiempo, memoria total, memoria usada, memoria libre, swap
    MEMORIA_TOTAL=$(free -m | awk 'NR==2{print $2}')
    MEMORIA_USADA=$(free -m | awk 'NR==2{print $3}')
    MEMORIA_LIBRE=$(free -m | awk 'NR==2{print $4}')
    SWAP_TOTAL=$(free -m | awk 'NR==3{print$2}')
    SWAP_USADA=$(free -m | awk 'NR==3{print$3}')
    echo "Hora: $HORA, MemoriaTotal: $MEMORIA_TOTAL, MemoriaUsada: $MEMORIA_USADA, MemoriaLibre: $MEMORIA_LIBRE, SwapTotal: $SWAP_TOTAL, SwapUsada: $SWAP_USADA"
    echo "$HORA, $MEMORIA_TOTAL, $MEMORIA_USADA, $MEMORIA_LIBRE, $SWAP_TOTAL, $SWAP_USADA" >> $ARCHIVO_CSV
    sleep "$TIEMPO_ESPERA"
done

INFORME="memoria_informe.txt"
tail -n +2 "$ARCHIVO_CSV" | awk -v ARCHIVO="$INFORME" -F ',' '
{
    MEM_TOTAL += $2; MEM_USADA += $3; MEM_LIBRE += $4; SWAP_TOTAL += $5; SWAP_USADA += $6
    if (NR == 1 || $2 > MAX_TOTAL) MAX_TOTAL = $2
    if (NR == 1 || $2 < MIN_TOTAL) MIN_TOTAL = $2
    if (NR == 1 || $3 > MAX_USADA) MAX_USADA = $3
    if (NR == 1 || $3 < MIN_USADA) MIN_USADA = $3
    if (NR == 1 || $4 > MAX_LIBRE) MAX_LIBRE = $4
    if (NR == 1 || $4 < MIN_LIBRE) MIN_LIBRE = $4
    if (NR == 1 || $6 > MAX_SWAP) MAX_SWAP_TOTAL = $5
    if (NR == 1 || $6 < MIN_SWAP) MIN_SWAP_TOTAL = $5
    if (NR == 1 || $7 > MAX_SWAP_USADA) MAX_SWAP_USADA = $6
    if (NR == 1 || $7 < MIN_SWAP_USADA) MIN_SWAP_USADA = $6
}
END {
    N = NR;
    print "Informe de Memoria\n" > ARCHIVO
    print "Promedios:" >> ARCHIVO
    printf "Memoria Total: %.2f MB\n", MEM_TOTAL/N >> ARCHIVO
    printf "Memoria Usada: %.2f MB\n", MEM_USADA/N >> ARCHIVO
    printf "Memoria Libre: %.2f MB\n", MEM_LIBRE/N >> ARCHIVO
    printf "Swap Total: %.2f MB\n", SWAP_TOTAL/N >> ARCHIVO
    printf "Swap Usada: %.2f MB\n\n", SWAP_USADA/N >> ARCHIVO

    print "Valores Máximos:" >> ARCHIVO
    print "Memoria Total:", MAX_TOTAL "MB" >> ARCHIVO
    print "Memoria Usada:", MAX_USADA "MB" >> ARCHIVO
    print "Memoria Libre:", MAX_LIBRE "MB" >> ARCHIVO
    print "Swap Total:", MAX_SWAP_TOTAL "MB" >> ARCHIVO
    print "Swap Usada:", MAX_SWAP_USADA "MB" >> ARCHIVO

    print "\nValores Mínimos:" >> ARCHIVO
    print "Memoria Total:", MIN_TOTAL "MB" >> ARCHIVO
    print "Memoria Usada:", MIN_USADA "MB" >> ARCHIVO
    print "Memoria Libre:", MIN_LIBRE "MB" >> ARCHIVO
    print "Swap Total:", MIN_SWAP_TOTAL "MB" >> ARCHIVO
    print "Swap Usada:", MIN_SWAP_USADA "MB" >> ARCHIVO
}
'
