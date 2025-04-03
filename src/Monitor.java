import java.lang.management.ManagementFactory;
import java.lang.management.OperatingSystemMXBean;
import java.lang.management.RuntimeMXBean;
public class Monitor {
    public static void main(String[] args) {
        // informacion del sistema
        OperatingSystemMXBean osBeans = ManagementFactory.getOperatingSystemMXBean();
        System.out.println("Sistema Operativo: \t" + osBeans.getName());
        System.out.println("Numero de CPUs: \t" + osBeans.getAvailableProcessors());
        System.out.println("Promedio de carga: %.2f \t\n" + osBeans.getSystemLoadAverage());

        // informacion de la jvm
        RuntimeMXBean runtimeBeans = ManagementFactory.getRuntimeMXBean();
        System.out.println("\nNombre de la MV de Java: \t" + runtimeBeans.getVmName());
        System.out.println("Tiempo de actividad: \t" + runtimeBeans.getUptime() + "ms");
        System.out.println("Argumento de entrada: \t" + runtimeBeans.getInputArguments());

        // informacion de memoria
        Runtime runtime = Runtime.getRuntime();
        System.out.println("\nMemoria Total: " + runtime.totalMemory() / (1024 * 1024) + " MB");
        System.out.println("Memoria Free: " + runtime.freeMemory() / (1024 * 1024) + " MB");
        System.out.println("Memoria Max: " + runtime.maxMemory() / (1024 * 1024) + " MB");

    }
}
