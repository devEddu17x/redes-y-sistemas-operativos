import java.util.LinkedList;
import java.util.Queue;
public class Proceso {
    int idP, tLlegada, tRafaga, tRestante;

    public Proceso(int idP, int tLlegada, int tRafaga) {
        this.idP = idP;
        this.tLlegada = tLlegada;
        this.tRafaga = tRafaga;
        this.tRestante = tRafaga;
    }

    @Override
    public String toString() {
        return "Proceso{" +
                "idP=" + idP +
                ", tRestante=" + tRestante +
                ", tLlegada=" + tLlegada +
                ", tRafaga=" + tRafaga +
                '}';
    }
}
