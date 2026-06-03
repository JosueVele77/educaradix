package io.github.josuevele77.educaradix.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = valueOrDefault("EDUCARADIX_DB_URL", "jdbc:postgresql://172.17.42.121:5432/DB_educa");
    private static final String USER = valueOrDefault("EDUCARADIX_DB_USER", "postgres");
    private static final String PASSWORD = valueOrDefault("EDUCARADIX_DB_PASSWORD", "1234");

    // Constructor privado para evitar que instancien la clase.
    private DatabaseConnection() {}

    public static Connection getConnection() throws SQLException {
        try {
            // Paso requerido para aplicaciones web: registrar el driver manualmente.
            Class.forName("org.postgresql.Driver");

            // Establece una nueva conexion en cada llamada.
            Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Nueva conexion a PostgreSQL generada exitosamente.");
            return con;

        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontro el driver de PostgreSQL. Revisa la dependencia Maven.", e);
        } catch (SQLException e) {
            System.err.println("Error: Fallo al conectar con la base de datos " + URL);
            throw e;
        }
    }

    private static String valueOrDefault(String key, String defaultValue) {
        String value = System.getenv(key);
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }
}
