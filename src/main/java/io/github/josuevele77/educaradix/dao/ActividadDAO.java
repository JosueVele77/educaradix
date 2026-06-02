package io.github.josuevele77.educaradix.dao;

import io.github.josuevele77.educaradix.config.DatabaseConnection;
import io.github.josuevele77.educaradix.models.ActividadEstudiante;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActividadDAO {
    public boolean crear(ActividadEstudiante actividad) {
        if (actualizarMisionExistente(actividad)) {
            return true;
        }
        String sql = "INSERT INTO actividades_estudiante (usuario_id, categoria, respuesta, puntaje, revisado, aprobado, comentario_admin) " +
                "VALUES (?, ?, ?, ?, true, true, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, actividad.getUsuarioId());
            ps.setString(2, actividad.getCategoria());
            ps.setString(3, actividad.getRespuesta());
            ps.setInt(4, actividad.getPuntaje());
            ps.setString(5, "Completado automaticamente por juego.");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ActividadEstudiante> listarPorUsuario(int usuarioId) {
        String sql = "SELECT a.*, u.nombre AS estudiante_nombre FROM actividades_estudiante a " +
                "JOIN usuarios u ON u.id = a.usuario_id WHERE a.usuario_id = ? ORDER BY a.fecha_registro DESC";
        return listar(sql, usuarioId);
    }

    public List<ActividadEstudiante> listarPendientes() {
        String sql = "SELECT a.*, u.nombre AS estudiante_nombre FROM actividades_estudiante a " +
                "JOIN usuarios u ON u.id = a.usuario_id WHERE a.revisado = false ORDER BY a.fecha_registro ASC";
        return listar(sql, null);
    }

    public List<ActividadEstudiante> listarTodas() {
        String sql = "SELECT a.*, u.nombre AS estudiante_nombre FROM actividades_estudiante a " +
                "JOIN usuarios u ON u.id = a.usuario_id ORDER BY a.fecha_registro DESC";
        return listar(sql, null);
    }

    public boolean revisar(int id, boolean aprobado, String comentarioAdmin) {
        String sql = "UPDATE actividades_estudiante SET revisado = true, aprobado = ?, comentario_admin = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, aprobado);
            ps.setString(2, comentarioAdmin);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int contarPendientes() {
        String sql = "SELECT COUNT(*) FROM actividades_estudiante WHERE revisado = false";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public List<String> clavesCompletadas(int usuarioId) {
        List<String> claves = new ArrayList<>();
        String sql = "SELECT DISTINCT LOWER(TRIM(categoria)) AS categoria FROM actividades_estudiante " +
                "WHERE usuario_id = ? AND puntaje >= 60";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    claves.add(claveMision(rs.getString("categoria")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return claves;
    }

    public Map<Integer, Integer> contarCompletadasPorUsuario() {
        Map<Integer, Integer> progreso = new HashMap<>();
        String sql = "SELECT usuario_id, COUNT(DISTINCT LOWER(TRIM(categoria))) AS completadas " +
                "FROM actividades_estudiante WHERE puntaje >= 60 GROUP BY usuario_id";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                progreso.put(rs.getInt("usuario_id"), rs.getInt("completadas"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return progreso;
    }

    private String claveMision(String categoria) {
        String normalizada = categoria == null ? "" : categoria.trim().toLowerCase();
        switch (normalizada) {
            case "potencias":
                return "potencias=32";
            case "raices":
                return "raices=12";
            case "radicales":
                return "radicales=3";
            case "comparaciones":
                return "comparaciones=64>36";
            case "memoria":
                return "memoria=2^3=8;raiz49=7;4^2=16";
            case "torre":
                return "torre=1000";
            case "laguna":
                return "laguna=2";
            default:
                return claveActividad(normalizada, "");
        }
    }

    private String claveActividad(String categoria, String respuesta) {
        String categoriaNormalizada = categoria == null ? "" : categoria.trim().toLowerCase();
        String respuestaNormalizada = respuesta == null ? "" : respuesta.trim().toLowerCase();
        return categoriaNormalizada + "=" + respuestaNormalizada;
    }

    private boolean actualizarMisionExistente(ActividadEstudiante actividad) {
        String sql = "UPDATE actividades_estudiante SET respuesta = ?, puntaje = GREATEST(puntaje, ?), " +
                "revisado = true, aprobado = true, comentario_admin = ?, fecha_registro = CURRENT_TIMESTAMP " +
                "WHERE usuario_id = ? AND LOWER(TRIM(categoria)) = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, actividad.getRespuesta());
            ps.setInt(2, actividad.getPuntaje());
            ps.setString(3, "Completado automaticamente por juego.");
            ps.setInt(4, actividad.getUsuarioId());
            ps.setString(5, actividad.getCategoria() == null ? "" : actividad.getCategoria().trim().toLowerCase());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private List<ActividadEstudiante> listar(String sql, Integer usuarioId) {
        List<ActividadEstudiante> actividades = new ArrayList<>();
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (usuarioId != null) {
                ps.setInt(1, usuarioId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    actividades.add(mapear(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return actividades;
    }

    private ActividadEstudiante mapear(ResultSet rs) throws SQLException {
        ActividadEstudiante actividad = new ActividadEstudiante();
        actividad.setId(rs.getInt("id"));
        actividad.setUsuarioId(rs.getInt("usuario_id"));
        actividad.setEstudianteNombre(rs.getString("estudiante_nombre"));
        actividad.setCategoria(rs.getString("categoria"));
        actividad.setRespuesta(rs.getString("respuesta"));
        actividad.setPuntaje(rs.getInt("puntaje"));
        actividad.setRevisado(rs.getBoolean("revisado"));
        actividad.setAprobado(rs.getBoolean("aprobado"));
        actividad.setComentarioAdmin(rs.getString("comentario_admin"));
        Timestamp fecha = rs.getTimestamp("fecha_registro");
        actividad.setFechaRegistro(fecha != null ? fecha.toLocalDateTime() : null);
        return actividad;
    }
}
