<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="io.github.josuevele77.educaradix.models.ActividadEstudiante" %>
<%@ page import="io.github.josuevele77.educaradix.models.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    List<ActividadEstudiante> actividades = (List<ActividadEstudiante>) request.getAttribute("actividades");
    Integer misionesCompletadas = (Integer) request.getAttribute("misionesCompletadas");
    Integer totalMisiones = (Integer) request.getAttribute("totalMisiones");
    Integer progresoPorcentaje = (Integer) request.getAttribute("progresoPorcentaje");
    String[] avatarSlugs = {"fox", "owl", "panda", "tiger", "koala", "capybara", "penguin", "lion", "rabbit", "wolf", "cat", "dog"};
    String avatarBase = "https://images.avataranimals.com/animals/transparent/";
    String avatarVersion = ".webp?v=a60026c088dc0dee";
    String avatarActual = usuario.getAvatarUrl() == null ? "" : usuario.getAvatarUrl();

    int intentos = actividades == null ? 0 : actividades.size();
    int puntajesPerfectos = 0;
    int pendientes = 0;
    int aprobadas = 0;
    Set<String> categoriasCompletadas = new HashSet<>();
    if (actividades != null) {
        for (ActividadEstudiante actividad : actividades) {
            if (actividad.getPuntaje() >= 100) {
                puntajesPerfectos++;
                categoriasCompletadas.add(actividad.getCategoria());
            }
            if (!actividad.isRevisado()) {
                pendientes++;
            } else if (actividad.isAprobado()) {
                aprobadas++;
            }
        }
    }
    int progresoActual = progresoPorcentaje == null ? 0 : progresoPorcentaje;
    int completadasActual = misionesCompletadas == null ? 0 : misionesCompletadas;
    int totalActual = totalMisiones == null ? 7 : totalMisiones;
    boolean tieneAvatar = !avatarActual.isEmpty();
    int dominioPotencias = 0;
    dominioPotencias += categoriasCompletadas.contains("potencias") ? 1 : 0;
    dominioPotencias += categoriasCompletadas.contains("torre") ? 1 : 0;
    dominioPotencias += categoriasCompletadas.contains("comparaciones") ? 1 : 0;
    int dominioRaices = 0;
    dominioRaices += categoriasCompletadas.contains("raices") ? 1 : 0;
    dominioRaices += categoriasCompletadas.contains("radicales") ? 1 : 0;
    dominioRaices += categoriasCompletadas.contains("laguna") ? 1 : 0;
    boolean memoriaCompleta = categoriasCompletadas.contains("memoria");

    String[][] logros = {
            {"Primer paso", "Completa tu primera mision en Jugar.", "Entra a Jugar y termina cualquier juego.", String.valueOf(Math.min(completadasActual, 1)), "1", "1"},
            {"Maestro de potencias", "Domina zorro, torre o portales de energia.", "Completa los juegos de potencias, torre y comparaciones.", String.valueOf(dominioPotencias), "3", "P"},
            {"Explorador de raices", "Resuelve cuadrados, cubos y bases escondidas.", "Completa sombra laser, maquina de cubos y laguna.", String.valueOf(dominioRaices), "3", "R"},
            {"Memoria nivel 10", "Supera todos los niveles del mapa de pares.", "Juega Memoria y termina sus 10 niveles.", memoriaCompleta ? "1" : "0", "1", "10"},
            {"Perfil con identidad", "Personaliza tu cuenta con avatar.", "Escoge un avatar en Ajustes y actualiza tu perfil.", tieneAvatar ? "1" : "0", "1", "AV"},
            {"Constancia", "Realiza al menos cinco intentos de practica.", "Juega varias rondas hasta registrar 5 actividades.", String.valueOf(Math.min(intentos, 5)), "5", "5x"},
            {"Ruta EducaRadix", "Completa todas las misiones disponibles.", "Termina los 7 juegos del apartado Jugar.", String.valueOf(completadasActual), String.valueOf(totalActual), "%"},
            {"Revision lista", "Ten actividades enviadas para revisar.", "Completa juegos y espera la revision del administrador.", String.valueOf(Math.min(pendientes + aprobadas, 3)), "3", "OK"}
    };

    List<String[]> logrosDesbloqueados = new ArrayList<>();
    for (String[] logro : logros) {
        int actual = Integer.parseInt(logro[3]);
        int meta = Integer.parseInt(logro[4]);
        if (meta > 0 && actual >= meta) {
            logrosDesbloqueados.add(logro);
        }
    }
    boolean mostrarLogrosDesbloqueados = request.getParameter("mensaje") != null && !logrosDesbloqueados.isEmpty();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Perfil | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="container py-4 profile-page">
    <div class="page-heading">
        <div>
            <p class="section-kicker">Estudiante</p>
            <h1 class="page-title">Mi perfil</h1>
        </div>
        <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/estudiante/jugar">Volver a jugar</a>
    </div>
    <% if (mostrarLogrosDesbloqueados) { %>
    <aside class="achievement-corner achievement-toast" aria-label="Logros desbloqueados">
        <strong>Logros desbloqueados</strong>
        <%
            int visibles = Math.min(logrosDesbloqueados.size(), 3);
            for (int i = 0; i < visibles; i++) {
                String[] logro = logrosDesbloqueados.get(i);
        %>
            <div class="corner-achievement"><span><%= logro[5] %></span><%= logro[0] %></div>
        <%  }
            if (logrosDesbloqueados.size() > visibles) { %>
            <span>+<%= logrosDesbloqueados.size() - visibles %> mas</span>
        <%  } %>
    </aside>
    <% } %>
    <% if (request.getParameter("mensaje") != null) { %>
        <div class="alert alert-success"><%= request.getParameter("mensaje") %></div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= request.getParameter("error") %></div>
    <% } %>
    <div class="row g-4">
        <div class="col-lg-4">
            <section class="profile-summary">
                <div class="profile-avatar-xl avatar-frame">
                    <% if (!avatarActual.isEmpty()) { %>
                        <img src="<%= avatarActual %>" alt="Avatar de <%= usuario.getNombre() %>">
                    <% } else { %>
                        <span><%= usuario.getNombre() != null && !usuario.getNombre().isEmpty() ? usuario.getNombre().substring(0, 1).toUpperCase() : "U" %></span>
                    <% } %>
                </div>
                <div>
                    <h2><%= usuario.getNombre() %></h2>
                    <p><%= usuario.getCorreo() %></p>
                </div>
                <div class="student-progress">
                    <div class="d-flex align-items-center justify-content-between gap-2">
                        <strong>Progreso</strong>
                        <span><%= misionesCompletadas == null ? 0 : misionesCompletadas %>/<%= totalMisiones == null ? 7 : totalMisiones %></span>
                    </div>
                    <div class="progress">
                        <div class="progress-bar progress-bar-animated-radix" style="width: <%= progresoActual %>%"></div>
                    </div>
                    <small><%= progresoActual %>% completado</small>
                </div>
            </section>

            <section class="auth-panel mt-4" id="ajustes">
                <h2 class="h4">Datos personales</h2>
                <form action="${pageContext.request.contextPath}/estudiante/perfil" method="post">
                    <div class="mb-3">
                        <label class="form-label" for="nombre">Nombre</label>
                        <input class="form-control" id="nombre" name="nombre" value="<%= usuario.getNombre() %>" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Correo</label>
                        <input class="form-control" value="<%= usuario.getCorreo() %>" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="clave">Clave nueva</label>
                        <input class="form-control" type="password" id="clave" name="clave" minlength="8" placeholder="Opcional">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Avatar</label>
                        <div class="avatar-picker">
                            <% for (String slug : avatarSlugs) {
                                String avatarUrl = avatarBase + slug + avatarVersion;
                            %>
                                <label class="avatar-option" title="<%= slug %>">
                                    <input type="radio" name="avatarUrl" value="<%= avatarUrl %>" <%= avatarUrl.equals(avatarActual) ? "checked" : "" %>>
                                    <span><img src="<%= avatarUrl %>" alt="Avatar <%= slug %>"></span>
                                </label>
                            <% } %>
                        </div>
                    </div>
                    <button class="btn btn-radix w-100" type="submit">Actualizar perfil</button>
                </form>
            </section>
        </div>
        <div class="col-lg-8">
            <section class="data-panel achievements-panel">
                <div class="achievements-head">
                    <div>
                        <p class="section-kicker mb-1">Progreso del estudiante</p>
                        <h2 class="h4 mb-0">Logros</h2>
                    </div>
                    <span><%= logrosDesbloqueados.size() %>/<%= logros.length %> desbloqueados</span>
                </div>
                <div class="achievement-grid">
                    <% for (String[] logro : logros) {
                        int actual = Integer.parseInt(logro[3]);
                        int meta = Integer.parseInt(logro[4]);
                        int porcentajeLogro = meta == 0 ? 0 : Math.min(100, Math.round((actual * 100f) / meta));
                        boolean desbloqueado = porcentajeLogro >= 100;
                    %>
                        <article class="achievement-card <%= desbloqueado ? "is-unlocked" : "" %>">
                            <div class="achievement-medal"><span><%= logro[5] %></span></div>
                            <div class="achievement-content">
                                <div class="achievement-title-row">
                                    <h3><%= logro[0] %></h3>
                                    <% if (desbloqueado) { %>
                                        <span class="achievement-badge">Logrado</span>
                                    <% } else { %>
                                        <span class="achievement-badge muted">En progreso</span>
                                    <% } %>
                                </div>
                                <p><%= logro[1] %></p>
                                <div class="achievement-how">
                                    <strong>Como realizar el logro</strong>
                                    <span><%= logro[2] %></span>
                                </div>
                                <div class="achievement-progress">
                                    <div class="d-flex justify-content-between gap-2">
                                        <small><%= actual %>/<%= meta %></small>
                                        <small><%= porcentajeLogro %>%</small>
                                    </div>
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-animated-radix" style="width: <%= porcentajeLogro %>%"></div>
                                    </div>
                                </div>
                            </div>
                        </article>
                    <% } %>
                </div>
            </section>
        </div>
    </div>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
