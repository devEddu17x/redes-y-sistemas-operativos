import java.io.*;
import java.net.Socket;

public class Cliente {
    public static void main(String[] args) throws IOException {
        Socket clienteSocket = new Socket("localhost", 3000);

        PrintWriter salida = new PrintWriter(clienteSocket.getOutputStream(), true);
        InputStreamReader input = new InputStreamReader(clienteSocket.getInputStream());
        BufferedReader entrada = new BufferedReader(input);
        InputStreamReader inputEstandar = new InputStreamReader(System.in);
        BufferedReader entradaEstandar = new BufferedReader(inputEstandar);

        String entradaUsuario;
        while ((entradaUsuario = entradaEstandar.readLine()) != null ) {
            salida.println(entradaUsuario);
            System.out.println(entrada.readLine());
        }

        salida.close();
        entrada.close();
        entradaEstandar.close();
        clienteSocket.close();
    }
}
