package io.github.josuevele77.educaradix.controllers;

import io.github.josuevele77.educaradix.dao.ActividadDAO;
import io.github.josuevele77.educaradix.dao.BitacoraDAO;
import io.github.josuevele77.educaradix.dao.UsuarioDAO;
import io.github.josuevele77.educaradix.models.ActividadEstudiante;
import io.github.josuevele77.educaradix.models.Categoria;
import io.github.josuevele77.educaradix.models.PasswordUtil;
import io.github.josuevele77.educaradix.models.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebServlet("/estudiante/*")
public class EstudianteController extends HttpServlet {
    private static final int TOTAL_MISIONES = 6;
    private static final String AVATAR_BASE = "https://images.avataranimals.com/animals/transparent/";
    private final ActividadDAO actividadDAO = new ActividadDAO();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final BitacoraDAO bitacoraDAO = new BitacoraDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        String path = request.getPathInfo();
        if (path == null || "/categorias".equals(path)) {
            request.setAttribute("categorias", categorias());
            cargarProgreso(request, usuario);
            request.getRequestDispatcher("/views/estudiante/categorias.jsp").forward(request, response);
            return;
        }
        if ("/jugar".equals(path)) {
            cargarProgreso(request, usuario);
            request.getRequestDispatcher("/views/estudiante/jugar.jsp").forward(request, response);
            return;
        }
        if ("/perfil".equals(path)) {
            request.setAttribute("actividades", actividadDAO.listarPorUsuario(usuario.getId()));
            cargarProgreso(request, usuario);
            request.getRequestDispatcher("/views/estudiante/perfil.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/estudiante/categorias");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();
        if ("/actividad".equals(path)) {
            guardarActividad(request, response);
            return;
        }
        if ("/perfil".equals(path)) {
            actualizarPerfil(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/estudiante/categorias");
    }

    private void guardarActividad(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        String categoria = normalizar(request.getParameter("categoria"));
        String respuesta = normalizar(request.getParameter("respuesta"));

        ActividadEstudiante actividad = new ActividadEstudiante();
        actividad.setUsuarioId(usuario.getId());
        actividad.setCategoria(categoria);
        actividad.setRespuesta(respuesta);
        actividad.setPuntaje(calcularPuntaje(categoria, respuesta));
        actividadDAO.crear(actividad);
        bitacoraDAO.registrar(usuario, "ACTIVIDAD_ESTUDIANTE", "Resolvio actividad de " + categoria);
        response.sendRedirect(request.getContextPath() + "/estudiante/perfil?mensaje=Respuesta enviada para revision.");
    }

    private void actualizarPerfil(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        String nombre = normalizar(request.getParameter("nombre"));
        String clave = request.getParameter("clave");
        String avatarUrl = normalizar(request.getParameter("avatarUrl"));
        boolean actualizarClave = clave != null && !clave.trim().isEmpty();
        if (nombre.isEmpty() || (actualizarClave && clave.length() < 8)) {
            response.sendRedirect(request.getContextPath() + "/estudiante/perfil?error=Revisa tu nombre y la clave minima de 8 caracteres.");
            return;
        }
        if (!avatarUrl.isEmpty() && !avatarValido(avatarUrl)) {
            response.sendRedirect(request.getContextPath() + "/estudiante/perfil?error=Selecciona un avatar valido de AvatarAnimals.");
            return;
        }

        boolean actualizado = usuarioDAO.actualizarPerfilEstudiante(
                usuario.getId(),
                nombre,
                actualizarClave ? PasswordUtil.sha256(clave) : null,
                actualizarClave,
                avatarUrl.isEmpty() ? null : avatarUrl
        );
        if (actualizado) {
            usuario.setNombre(nombre);
            usuario.setAvatarUrl(avatarUrl.isEmpty() ? null : avatarUrl);
            request.getSession().setAttribute("usuario", usuario);
            bitacoraDAO.registrar(usuario, "ACTUALIZAR_PERFIL", "El estudiante actualizo su perfil.");
        }
        response.sendRedirect(request.getContextPath() + "/estudiante/perfil?mensaje=Perfil actualizado.");
    }

    private int calcularPuntaje(String categoria, String respuesta) {
        String limpia = respuesta.toLowerCase().replace(" ", "");
        if ("potencias".equals(categoria) && ("32".equals(limpia) || "2^5=32".equals(limpia))) {
            return 100;
        }
        if ("raices".equals(categoria) && ("12".equals(limpia) || "sqrt(144)=12".equals(limpia))) {
            return 100;
        }
        if ("radicales".equals(categoria) && ("3".equals(limpia) || "27^(1/3)=3".equals(limpia))) {
            return 100;
        }
        if ("comparaciones".equals(categoria) && ("64>36".equals(limpia) || "2^6>6^2".equals(limpia))) {
            return 100;
        }
        if ("memoria".equals(categoria) && "2^3=8;raiz49=7;4^2=16".equals(limpia)) {
            return 100;
        }
        if ("torre".equals(categoria) && ("1000".equals(limpia) || "10^3=1000".equals(limpia))) {
            return 100;
        }
        return 60;
    }

    private void cargarProgreso(HttpServletRequest request, Usuario usuario) {
        List<String> clavesCompletadas = actividadDAO.clavesCompletadas(usuario.getId());
        int completadas = Math.min(clavesCompletadas.size(), TOTAL_MISIONES);
        int porcentaje = Math.round((completadas * 100f) / TOTAL_MISIONES);
        request.setAttribute("clavesCompletadas", clavesCompletadas);
        request.setAttribute("misionesCompletadas", completadas);
        request.setAttribute("totalMisiones", TOTAL_MISIONES);
        request.setAttribute("progresoPorcentaje", porcentaje);
    }

    private boolean avatarValido(String avatarUrl) {
        return avatarUrl.startsWith(AVATAR_BASE)
                && avatarUrl.contains(".webp")
                && !avatarUrl.contains(" ")
                && avatarUrl.length() <= 260;
    }

    private List<Categoria> categorias() {
        return Arrays.asList(
                new Categoria("potencias", "Potencias", "Multiplicacion repetida con base y exponente.", "Cuanto es 2^5?", "Duplica cinco veces desde 1."),
                new Categoria("raices", "Raices cuadradas", "La operacion inversa de elevar al cuadrado.", "Cuanto es raiz cuadrada de 144?", "Busca el numero que al cuadrado da 144."),
                new Categoria("radicales", "Potencias fraccionarias", "Relacion entre radicales y exponentes racionales.", "Cuanto es 27^(1/3)?", "Es la raiz cubica de 27.")
        );
    }

    private String normalizar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
