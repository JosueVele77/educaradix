package io.github.josuevele77.educaradix.dao;

import io.github.josuevele77.educaradix.config.DatabaseConnection;
import io.github.josuevele77.educaradix.models.Bitacora;
import io.github.josuevele77.educaradix.models.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class BitacoraDAO {
    public void registrar(Usuario usuario, String accion, String detalle) {
        String sql = "INSERT INTO bitacora (usuario_id, usuario_nombre, accion, detalle) VALUES (?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (usuario != null) {
                ps.setInt(1, usuario.getId());
                ps.setString(2, usuario.getNombre());
            } else {
                ps.setObject(1, null);
                ps.setString(2, "Invitado");
            }
            ps.setString(3, accion);
            ps.setString(4, detalle);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Bitacora> listar(int limite) {
        List<Bitacora> registros = new ArrayList<>();
        String sql = "SELECT * FROM bitacora ORDER BY fecha DESC LIMIT ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bitacora bitacora = new Bitacora();
                    bitacora.setId(rs.getInt("id"));
                    int usuarioId = rs.getInt("usuario_id");
                    bitacora.setUsuarioId(rs.wasNull() ? null : usuarioId);
                    bitacora.setUsuarioNombre(rs.getString("usuario_nombre"));
                    bitacora.setAccion(rs.getString("accion"));
                    bitacora.setDetalle(rs.getString("detalle"));
                    Timestamp fecha = rs.getTimestamp("fecha");
                    bitacora.setFecha(fecha != null ? fecha.toLocalDateTime() : null);
                    registros.add(bitacora);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registros;
    }
}
