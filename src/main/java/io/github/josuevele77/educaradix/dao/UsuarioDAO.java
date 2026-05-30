package io.github.josuevele77.educaradix.dao;

import io.github.josuevele77.educaradix.config.DatabaseConnection;
import io.github.josuevele77.educaradix.models.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {
    private static boolean avatarColumnChecked = false;

    public UsuarioDAO() {
        asegurarColumnaAvatar();
    }

    private void asegurarColumnaAvatar() {
        if (avatarColumnChecked) {
            return;
        }
        String sql = "ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(260)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
            avatarColumnChecked = true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean crear(Usuario usuario) {
        String sql = "INSERT INTO usuarios (nombre, correo, clave, rol, bloqueado, avatar_url) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getCorreo());
            ps.setString(3, usuario.getClave());
            ps.setString(4, usuario.getRol());
            ps.setBoolean(5, usuario.isBloqueado());
            ps.setString(6, usuario.getAvatarUrl());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Usuario buscarPorCorreo(String correo) {
        String sql = "SELECT * FROM usuarios WHERE correo = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Usuario buscarPorId(int id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Usuario> listarTodos() {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios ORDER BY id DESC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                usuarios.add(mapear(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuarios;
    }

    public List<Usuario> listarPublicos() {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios ORDER BY fecha_registro DESC LIMIT 20";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                usuarios.add(mapear(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuarios;
    }

    public boolean actualizar(Usuario usuario, boolean actualizarClave) {
        String sql = actualizarClave
                ? "UPDATE usuarios SET nombre = ?, correo = ?, clave = ?, rol = ?, bloqueado = ?, ultima_actualizacion = NOW() WHERE id = ?"
                : "UPDATE usuarios SET nombre = ?, correo = ?, rol = ?, bloqueado = ?, ultima_actualizacion = NOW() WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getCorreo());
            if (actualizarClave) {
                ps.setString(3, usuario.getClave());
                ps.setString(4, usuario.getRol());
                ps.setBoolean(5, usuario.isBloqueado());
                ps.setInt(6, usuario.getId());
            } else {
                ps.setString(3, usuario.getRol());
                ps.setBoolean(4, usuario.isBloqueado());
                ps.setInt(5, usuario.getId());
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizarPerfilEstudiante(int id, String nombre, String claveHash, boolean actualizarClave) {
        return actualizarPerfilEstudiante(id, nombre, claveHash, actualizarClave, null);
    }

    public boolean actualizarPerfilEstudiante(int id, String nombre, String claveHash, boolean actualizarClave, String avatarUrl) {
        String sql = actualizarClave
                ? "UPDATE usuarios SET nombre = ?, clave = ?, avatar_url = ?, ultima_actualizacion = NOW() WHERE id = ?"
                : "UPDATE usuarios SET nombre = ?, avatar_url = ?, ultima_actualizacion = NOW() WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombre);
            if (actualizarClave) {
                ps.setString(2, claveHash);
                ps.setString(3, avatarUrl);
                ps.setInt(4, id);
            } else {
                ps.setString(2, avatarUrl);
                ps.setInt(3, id);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cambiarBloqueo(int id, boolean bloqueado) {
        String sql = "UPDATE usuarios SET bloqueado = ?, ultima_actualizacion = NOW() WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, bloqueado);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int contarPorRol(String rol) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE rol = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, rol);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int contarBloqueados() {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE bloqueado = true";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    private Usuario mapear(ResultSet rs) throws SQLException {
        Timestamp fecha = rs.getTimestamp("fecha_registro");
        Timestamp actualizacion = rs.getTimestamp("ultima_actualizacion");
        Usuario usuario = new Usuario(
                rs.getInt("id"),
                rs.getString("nombre"),
                rs.getString("correo"),
                rs.getString("clave"),
                rs.getString("rol"),
                rs.getBoolean("bloqueado"),
                fecha != null ? fecha.toLocalDateTime() : null,
                actualizacion != null ? actualizacion.toLocalDateTime() : null
        );
        usuario.setAvatarUrl(rs.getString("avatar_url"));
        return usuario;
    }
}
