import java.util.LinkedList;
import java.util.Queue;

public class PlanRoundBin {

    public static void main(String[] args) {
        Proceso[] procesos = {
                new Proceso(0,0,10),
                new Proceso(1,1,5),
                new Proceso(2,2,8)
        };

        planRoundBin(procesos, 3);
    }

    public static void planRoundBin(Proceso[] procesos, int quantum) {
        Queue<Proceso> cola = new LinkedList<>();
        int tActual = 0;
        int [] tEspera = new int[procesos.length];
        int [] tRespuesta = new int[procesos.length];
        // simular llegada de procesos
        for (Proceso proceso: procesos) {
            cola.add(proceso);
        }

        while (!cola.isEmpty()) {
            Proceso pActual = cola.poll();
            int tEjecucion = Math.min(quantum, pActual.tRestante);
            tActual += tEjecucion;
            pActual.tRestante -= tEjecucion;
            if (pActual.tRestante > 0) {
                cola.add(pActual);
            } else {
                tRespuesta[pActual.idP] = tActual - pActual.tLlegada;;
                tEspera[pActual.idP] = tRespuesta[pActual.idP] - pActual.tRafaga;
            }
        }

        // resultados
        System.out.println("ID Proceso \tTiempo de Espera\tTiempo de Retorno");
        for (Proceso p: procesos) {
            System.out.println("\t"+p.idP+"\t\t\t\t"+tEspera[p.idP]+"\t\t\t\t"+tRespuesta[p.idP]+"\n");
        }
    }
}
