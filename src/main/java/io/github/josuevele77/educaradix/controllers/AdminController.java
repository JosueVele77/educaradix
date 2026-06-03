package io.github.josuevele77.educaradix.controllers;

import io.github.josuevele77.educaradix.dao.ActividadDAO;
import io.github.josuevele77.educaradix.dao.BitacoraDAO;
import io.github.josuevele77.educaradix.dao.UsuarioDAO;
import io.github.josuevele77.educaradix.models.PasswordUtil;
import io.github.josuevele77.educaradix.models.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminController extends HttpServlet {
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final ActividadDAO actividadDAO = new ActividadDAO();
    private final BitacoraDAO bitacoraDAO = new BitacoraDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null || "/dashboard".equals(path)) {
            cargarDashboard(request, response);
            return;
        }
        if ("/usuarios".equals(path)) {
            request.setAttribute("usuarios", usuarioDAO.listarTodos());
            request.setAttribute("progresoUsuarios", actividadDAO.contarCompletadasPorUsuario());
            request.setAttribute("totalMisiones", 7);
            request.getRequestDispatcher("/views/admin/usuarios.jsp").forward(request, response);
            return;
        }
        if ("/bitacora".equals(path)) {
            request.setAttribute("bitacora", bitacoraDAO.listar(200));
            request.getRequestDispatcher("/views/admin/bitacora.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();
        if ("/usuarios".equals(path)) {
            gestionarUsuarios(request, response);
            return;
        }
        if ("/actividades".equals(path)) {
            revisarActividad(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }

    private void cargarDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("totalEstudiantes", usuarioDAO.contarPorRol("ESTUDIANTE"));
        request.setAttribute("totalAdmins", usuarioDAO.contarPorRol("ADMIN"));
        request.setAttribute("totalBloqueados", usuarioDAO.contarBloqueados());
        request.setAttribute("actividadesPendientes", actividadDAO.contarPendientes());
        request.setAttribute("pendientes", actividadDAO.listarPendientes());
        request.setAttribute("actividades", actividadDAO.listarTodas());
        request.setAttribute("usuarios", usuarioDAO.listarTodos());
        request.setAttribute("progresoUsuarios", actividadDAO.contarCompletadasPorUsuario());
        request.setAttribute("totalMisiones", 7);
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    private void gestionarUsuarios(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuario");
        String accion = request.getParameter("accion");
        if ("crear".equals(accion)) {
            crearUsuario(request, admin);
        } else if ("actualizar".equals(accion)) {
            actualizarUsuario(request, admin);
        } else if ("bloquear".equals(accion)) {
            int id = parseInt(request.getParameter("id"));
            boolean bloquear = Boolean.parseBoolean(request.getParameter("bloqueado"));
            usuarioDAO.cambiarBloqueo(id, bloquear);
            bitacoraDAO.registrar(admin, bloquear ? "BLOQUEO_USUARIO" : "DESBLOQUEO_USUARIO", "Usuario ID " + id);
        }
        response.sendRedirect(request.getContextPath() + "/admin/usuarios");
    }

    private void crearUsuario(HttpServletRequest request, Usuario admin) {
        String clave = request.getParameter("clave");
        if (clave == null || clave.length() < 8) {
            return;
        }
        Usuario usuario = new Usuario();
        usuario.setNombre(normalizar(request.getParameter("nombre")));
        usuario.setCorreo(normalizar(request.getParameter("correo")));
        usuario.setClave(PasswordUtil.sha256(clave));
        usuario.setRol(request.getParameter("rol"));
        usuario.setBloqueado(false);
        if (usuarioDAO.crear(usuario)) {
            bitacoraDAO.registrar(admin, "CREAR_USUARIO", "Nuevo usuario: " + usuario.getCorreo());
        }
    }

    private void actualizarUsuario(HttpServletRequest request, Usuario admin) {
        String clave = request.getParameter("clave");
        Usuario usuario = new Usuario();
        usuario.setId(parseInt(request.getParameter("id")));
        usuario.setNombre(normalizar(request.getParameter("nombre")));
        usuario.setCorreo(normalizar(request.getParameter("correo")));
        usuario.setRol(request.getParameter("rol"));
        usuario.setBloqueado(Boolean.parseBoolean(request.getParameter("bloqueadoActual")));
        boolean actualizarClave = clave != null && !clave.trim().isEmpty();
        if (actualizarClave && clave.length() < 8) {
            return;
        }
        if (actualizarClave) {
            usuario.setClave(PasswordUtil.sha256(clave));
        }
        if (usuarioDAO.actualizar(usuario, actualizarClave)) {
            bitacoraDAO.registrar(admin, "ACTUALIZAR_USUARIO", "Usuario actualizado: " + usuario.getCorreo());
        }
    }

    private void revisarActividad(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuario");
        int id = parseInt(request.getParameter("id"));
        boolean aprobado = Boolean.parseBoolean(request.getParameter("aprobado"));
        String comentario = normalizar(request.getParameter("comentario"));
        if (actividadDAO.revisar(id, aprobado, comentario)) {
            bitacoraDAO.registrar(admin, "REVISION_ACTIVIDAD", "Actividad ID " + id + " revisada.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }

    private int parseInt(String valor) {
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String normalizar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
