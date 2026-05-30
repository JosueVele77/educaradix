package io.github.josuevele77.educaradix.dao;

import io.github.josuevele77.educaradix.config.DatabaseConnection;
import io.github.josuevele77.educaradix.models.ActividadEstudiante;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ActividadDAO {
    public boolean crear(ActividadEstudiante actividad) {
        String sql = "INSERT INTO actividades_estudiante (usuario_id, categoria, respuesta, puntaje) VALUES (?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, actividad.getUsuarioId());
            ps.setString(2, actividad.getCategoria());
            ps.setString(3, actividad.getRespuesta());
            ps.setInt(4, actividad.getPuntaje());
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
        String sql = "SELECT DISTINCT categoria, respuesta FROM actividades_estudiante " +
                "WHERE usuario_id = ? AND puntaje >= 100";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    claves.add(claveActividad(rs.getString("categoria"), rs.getString("respuesta")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return claves;
    }

    private String claveActividad(String categoria, String respuesta) {
        String categoriaNormalizada = categoria == null ? "" : categoria.trim().toLowerCase();
        String respuestaNormalizada = respuesta == null ? "" : respuesta.trim().toLowerCase();
        return categoriaNormalizada + "=" + respuestaNormalizada;
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
