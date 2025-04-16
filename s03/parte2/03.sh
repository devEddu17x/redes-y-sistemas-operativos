NAVEGADORES=("firefox" "google-chrome-stable")
NOMBRE_PROCESOS=("firefox" "chrome")
URL=https://www.google.com
PEST=10
abrir_pest() {
    for ((i=1; i <= PEST; i++)); do
        for ((j=0; j<${#NAVEGADORES[@]}; j++)); do
            ${NAVEGADORES[j]} $URL &> /dev/null &
            sleep 1
        done        
    done
}

abrir_pest
ARCHIVO_CSV="navegadores.csv"
monitorear() {

    echo "navegador,memoria">"$ARCHIVO_CSV"
    for ((k=1; k<=10; k++)); do
        for ((i=0; i<${#NOMBRE_PROCESOS[@]}; i++)); do

            # total
            ps -eo comm,%mem,pid | grep "${NOMBRE_PROCESOS[i]}" | awk -v ARCHIVO="$ARCHIVO_CSV" -v NAVEGADOR="${NOMBRE_PROCESOS[i]}" '
                {
                    MEM_TOTAL += $2;
                    
                    #printf "PID:%d, NAVEGADOR:%s, MEMORIA:%.2f\n", $3, NAVEGADOR, $2
                } 
                END {
                    print "----------------------------------------"
                    printf "Memoria: %s: %.2f%\n", NAVEGADOR, MEM_TOTAL
                    printf "%s,%.2f\n", NAVEGADOR, MEM_TOTAL >> ARCHIVO

                }'
        done
        sleep 2
    done

    echo "----------------------------------------"
    echo "Fin de la medición de memoria"

}

monitorear


evaluar() {

    awk -F ',' 'NR>1 {
        navegador = $1
        memoria = $2

        if (!(navegador in count)) {
            count[navegador] = 0
            sum[navegador] = 0
            first[navegador] = memoria
            min[navegador] = memoria
            max[navegador] = memoria
        }
        
        count[navegador]++
        sum[navegador] += memoria
        last[navegador] = memoria
        
        if (memoria < min[navegador]) { min[navegador] = memoria }
        if (memoria > max[navegador]) { max[navegador] = memoria }
    }
    END {
        for (navegador in count) {
            promedio = sum[navegador] / count[navegador]
            variacion = last[navegador] - first[navegador]
            print navegador ":"
            printf "\tPromedio: %.2f%\n", promedio
            printf "\tMínimo: %.2f%\n", min[navegador]
            printf "\tMáximo: %.2f%\n", max[navegador]
            printf "\tVariación (desde el primer hasta el último valor): %.2f%\n", variacion
        }
    }' "$ARCHIVO_CSV"
}

evaluar