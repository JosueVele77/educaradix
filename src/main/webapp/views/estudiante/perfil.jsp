<%@ page import="java.util.List" %>
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
<main class="container py-4">
    <div class="page-heading">
        <div>
            <p class="section-kicker">Estudiante</p>
            <h1 class="page-title">Mi perfil</h1>
        </div>
        <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/estudiante/jugar">Volver a jugar</a>
    </div>
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
                        <span><%= misionesCompletadas == null ? 0 : misionesCompletadas %>/<%= totalMisiones == null ? 6 : totalMisiones %></span>
                    </div>
                    <div class="progress">
                        <div class="progress-bar" style="width: <%= progresoPorcentaje == null ? 0 : progresoPorcentaje %>%"></div>
                    </div>
                    <small><%= progresoPorcentaje == null ? 0 : progresoPorcentaje %>% completado</small>
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
                        <a class="small d-inline-block mt-2" href="https://avataranimals.com/animals" target="_blank" rel="noopener noreferrer">Ver mas avatares en AvatarAnimals</a>
                    </div>
                    <button class="btn btn-radix w-100" type="submit">Actualizar perfil</button>
                </form>
            </section>
        </div>
        <div class="col-lg-8">
            <section class="data-panel">
                <h2 class="h4">Mis actividades</h2>
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Categoria</th>
                            <th>Respuesta</th>
                            <th>Puntaje</th>
                            <th>Estado</th>
                            <th>Comentario</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% if (actividades == null || actividades.isEmpty()) { %>
                            <tr><td colspan="6" class="text-muted">Aun no has enviado actividades.</td></tr>
                        <% } else {
                            for (ActividadEstudiante a : actividades) { %>
                                <tr>
                                    <td><%= a.getFechaRegistro() %></td>
                                    <td><%= a.getCategoria() %></td>
                                    <td><%= a.getRespuesta() %></td>
                                    <td><%= a.getPuntaje() %></td>
                                    <td>
                                        <% if (!a.isRevisado()) { %>
                                            <span class="badge text-bg-warning">Pendiente</span>
                                        <% } else if (a.isAprobado()) { %>
                                            <span class="badge text-bg-success">Aprobado</span>
                                        <% } else { %>
                                            <span class="badge text-bg-danger">Observado</span>
                                        <% } %>
                                    </td>
                                    <td><%= a.getComentarioAdmin() == null ? "" : a.getComentarioAdmin() %></td>
                                </tr>
                        <%  }
                           } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
