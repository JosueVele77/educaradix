package io.github.josuevele77.educaradix.controllers;

import io.github.josuevele77.educaradix.dao.BitacoraDAO;
import io.github.josuevele77.educaradix.dao.UsuarioDAO;
import io.github.josuevele77.educaradix.models.PasswordUtil;
import io.github.josuevele77.educaradix.models.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet({"/login", "/registro", "/logout"})
public class AuthController extends HttpServlet {
    private static final Pattern EMAIL_VALIDO = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final BitacoraDAO bitacoraDAO = new BitacoraDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession sessionActual = request.getSession(false);
        Usuario usuarioActual = sessionActual != null ? (Usuario) sessionActual.getAttribute("usuario") : null;
        if ("/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            Usuario usuario = session != null ? (Usuario) session.getAttribute("usuario") : null;
            bitacoraDAO.registrar(usuario, "CIERRE_SESION", "El usuario cerro sesion.");
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login?mensaje=Sesion cerrada correctamente.");
            return;
        }

        if (usuarioActual != null) {
            redirigirSegunRol(request, response, usuarioActual);
            return;
        }

        if ("/registro".equals(path)) {
            request.setAttribute("usuariosPublicos", usuarioDAO.listarPublicos());
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        Usuario usuarioActual = (Usuario) request.getSession().getAttribute("usuario");
        if (usuarioActual != null) {
            redirigirSegunRol(request, response, usuarioActual);
            return;
        }
        if ("/registro".equals(path)) {
            registrar(request, response);
            return;
        }
        iniciarSesion(request, response);
    }

    private void iniciarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String correo = normalizar(request.getParameter("correo"));
        String clave = request.getParameter("clave");

        Usuario usuario = usuarioDAO.buscarPorCorreo(correo);
        if (usuario == null || clave == null || !PasswordUtil.sha256(clave).equals(usuario.getClave())) {
            bitacoraDAO.registrar(null, "LOGIN_FALLIDO", "Intento fallido para el correo " + correo);
            response.sendRedirect(request.getContextPath() + "/login?error=Credenciales incorrectas.");
            return;
        }

        if (usuario.isBloqueado()) {
            bitacoraDAO.registrar(usuario, "LOGIN_BLOQUEADO", "Intento de ingreso con usuario bloqueado.");
            response.sendRedirect(request.getContextPath() + "/login?error=Tu usuario esta bloqueado.");
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("usuario", usuario);
        bitacoraDAO.registrar(usuario, "INICIO_SESION", "Ingreso al sistema.");
        redirigirSegunRol(request, response, usuario);
    }

    private void registrar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String nombre = normalizar(request.getParameter("nombre"));
        String correo = normalizar(request.getParameter("correo"));
        String clave = request.getParameter("clave");

        if (nombre.isEmpty() || correo.isEmpty() || clave == null || clave.length() < 8) {
            response.sendRedirect(request.getContextPath() + "/registro?error=Completa los datos. La clave debe tener minimo 8 caracteres.");
            return;
        }

        if (!EMAIL_VALIDO.matcher(correo).matches()) {
            response.sendRedirect(request.getContextPath() + "/registro?error=Ingresa un correo valido.");
            return;
        }

        if (usuarioDAO.buscarPorCorreo(correo) != null) {
            response.sendRedirect(request.getContextPath() + "/registro?error=El correo ya esta registrado.");
            return;
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(nombre);
        usuario.setCorreo(correo);
        usuario.setClave(PasswordUtil.sha256(clave));
        usuario.setRol("ESTUDIANTE");
        usuario.setBloqueado(false);

        if (usuarioDAO.crear(usuario)) {
            bitacoraDAO.registrar(null, "REGISTRO_PUBLICO", "Nuevo estudiante registrado: " + correo);
            response.sendRedirect(request.getContextPath() + "/login?mensaje=Registro exitoso. Ya puedes iniciar sesion.");
        } else {
            response.sendRedirect(request.getContextPath() + "/registro?error=No se pudo registrar el usuario.");
        }
    }

    private String normalizar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private void redirigirSegunRol(HttpServletRequest request, HttpServletResponse response, Usuario usuario) throws IOException {
        if ("ADMIN".equals(usuario.getRol())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/estudiante/categorias");
    }
}
