package io.github.josuevele77.educaradix.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:postgresql://localhost:5432/educaradix";
    private static final String USER = "postgres"; // Asegúrate de que sean tus credenciales correctas
    private static final String PASSWORD = "root";

    // ELIMINAMOS la variable 'private static Connection connection'

    // Constructor privado para evitar que instancien la clase
    private DatabaseConnection() {}

    public static Connection getConnection() {
        Connection con = null; // Creamos una variable local
        try {
            // Paso requerido para aplicaciones web: registrar el driver manualmente
            Class.forName("org.postgresql.Driver");

            // Establecer una NUEVA conexión cada vez que se llama a este método
            con = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Nueva conexión a PostgreSQL generada exitosamente.");

        } catch (ClassNotFoundException e) {
            System.err.println("Error: No se encontró el Driver de PostgreSQL. Revisa el .jar");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Error: Fallo al conectar con la base de datos.");
            e.printStackTrace();
        }
        return con; // Retornamos la conexión fresca
    }
}