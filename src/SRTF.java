import java.util.*;

public class SRTF {
    public static void main(String[] args) {
        Proceso[] procesos = {
                new Proceso(1,0,9),
                new Proceso(2,1,2),
                new Proceso(3,2,3),
                new Proceso(4,3,1),
                new Proceso(5,4,5)
        };
        srtf(procesos);
    }

    public static void srtf(Proceso[] procesos) {
        LinkedList<Proceso> todosProcesos = new LinkedList<>();
        Collections.addAll(todosProcesos, procesos);
        LinkedList<Proceso> procesosCola = new LinkedList<>();

        int tActual = 0;
        int[] tEspera = new int[procesos.length];
        int[] tRetorno = new int[procesos.length];

        while (!todosProcesos.isEmpty() || !procesosCola.isEmpty()) {
            // aqui se agregan los procesos en su tiempo de llegada
            while (!todosProcesos.isEmpty() && todosProcesos.getFirst().tLlegada <= tActual) {
                procesosCola.add(todosProcesos.removeFirst());
            }
            // en caso no haya procesos, avanzar el tiempo actual hasta el siguiente tiempo de llegada
            if (procesosCola.isEmpty()) { // solo si la cola de procesos esta vacia
                if (!todosProcesos.isEmpty()) { // y aun hay procesos disponibles
                    tActual = todosProcesos.getFirst().tLlegada;
                    continue;
                } else {
                    break;  // fin
                }
            }
            procesosCola.sort((p1, p2) -> p1.tRestante - p2.tRestante);
            Proceso pActual = procesosCola.removeFirst();
            // se disminuye un sgundo al proceso actual
            pActual.tRestante--;
            // si el proceso termina se registra sus datos
            if (pActual.tRestante == 0) {
                tRetorno[pActual.idP - 1] = tActual + 1 - pActual.tLlegada;
                tEspera[pActual.idP - 1] = tRetorno[pActual.idP - 1] - pActual.tRafaga;
            } else {
                // si el proceso no ha terminado entonces debe ser devuelto a la cola
                // para seguir procesnadose
                procesosCola.add(pActual);
            }
            tActual++;
        }

        System.out.println("\nID\tT. Ejc\tT. Esp.\tT. Ret.");
        for (int i = 0; i < procesos.length; i++) {
            System.out.println(procesos[i].idP + "\t\t" + procesos[i].tRafaga + "\t\t" + tEspera[i] + "\t\t" + tRetorno[i]);
        }

        double promedioEspera = promedio(tEspera);
        double promedioRetorno = promedio(tRetorno);

        System.out.println("\nTiempo de espera promedio: " + promedioEspera);
        System.out.println("Tiempo de retorno promedio: " + promedioRetorno);
    }

    public static double promedio(int[] arrglo) {
        int suma = 0;
        for (int i = 0; i < arrglo.length; i++) {
            suma += arrglo[i];
        }
        return (double) suma/ arrglo.length;
    }
}
