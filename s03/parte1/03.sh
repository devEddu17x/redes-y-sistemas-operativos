#!/bash/bin
while true; do
    clear
    echo -e "Informe de memoria\n   PID\tComando\t\t%CPU  %Mem" 
    ps -eo pid,comm,%cpu,%mem --sort=-%mem | awk '$(NF-1) > 1'
    echo "s: Save | q: Quit"
    read -t 2 -N 1 TECLA
    if [[ $TECLA == "s" ]]; then
        echo -e "Informe de memoria\n   PID\tComando\t\t%CPU  %Mem"  > informe_memoria.txt
        ps -eo pid,comm,%cpu,%mem --sort=-%mem | awk '$(NF-1) > 1' >> informe_memoria.txt
        break
    elif [[ $TECLA == "q" ]]; then
        break
    fi
done;