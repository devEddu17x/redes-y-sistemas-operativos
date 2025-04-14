import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class Servidor {
    public static void main(String[] args) throws IOException {
        ServerSocket servidorSocket = new ServerSocket(3000);
        System.out.println("Servidor esperando conexiones");

        Socket clienteSocket = servidorSocket.accept();
        System.out.println("Cliente conectado: " + clienteSocket.getInetAddress());

        PrintWriter salida = new PrintWriter(clienteSocket.getOutputStream(), true);
        InputStreamReader input = new InputStreamReader(clienteSocket.getInputStream());
        BufferedReader entrada = new BufferedReader(input);

        String mensaje;
        while ( (mensaje = entrada.readLine()) != null ) {
            System.out.println("Mensaje recibido: " + mensaje);
            salida.println("Mensaje de retorno: " + mensaje);
        }

        entrada.close();
        salida.close();
        clienteSocket.close();
        servidorSocket.close();
    }
}
