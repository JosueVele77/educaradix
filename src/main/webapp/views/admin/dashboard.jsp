<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="io.github.josuevele77.educaradix.models.ActividadEstudiante" %>
<%@ page import="io.github.josuevele77.educaradix.models.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<ActividadEstudiante> actividades = (List<ActividadEstudiante>) request.getAttribute("actividades");
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    Map<Integer, Integer> progresoUsuarios = (Map<Integer, Integer>) request.getAttribute("progresoUsuarios");
    Integer totalMisiones = (Integer) request.getAttribute("totalMisiones");
    int total = totalMisiones == null ? 7 : totalMisiones;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel admin | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="container py-4 admin-shell">
    <div class="admin-title-row">
        <div>
            <p class="section-kicker">Administrador</p>
            <h1 class="page-title">Panel de control</h1>
        </div>
        <a class="btn btn-radix" href="${pageContext.request.contextPath}/admin/usuarios">Crear cuenta</a>
    </div>
    <div class="row g-3 mb-4">
        <div class="col-md-3"><div class="metric-card metric-teal"><span>Estudiantes</span><strong><%= request.getAttribute("totalEstudiantes") %></strong></div></div>
        <div class="col-md-3"><div class="metric-card metric-violet"><span>Administradores</span><strong><%= request.getAttribute("totalAdmins") %></strong></div></div>
        <div class="col-md-3"><div class="metric-card metric-coral"><span>Bloqueados</span><strong><%= request.getAttribute("totalBloqueados") %></strong></div></div>
        <div class="col-md-3"><div class="metric-card metric-amber"><span>Por revisar</span><strong><%= request.getAttribute("actividadesPendientes") %></strong></div></div>
    </div>
    <section class="data-panel admin-panel-accent account-status-panel mb-4">
        <div class="d-flex align-items-center justify-content-between gap-3 mb-3">
            <div>
                <p class="section-kicker mb-1">Cuentas</p>
                <h2 class="h4 mb-0">Estado de cuentas creadas</h2>
            </div>
            <a class="btn btn-outline-dark btn-sm" href="${pageContext.request.contextPath}/admin/usuarios">Gestionar usuarios</a>
        </div>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Rol</th>
                    <th>Estado</th>
                    <th>Progreso</th>
                </tr>
                </thead>
                <tbody>
                <% if (usuarios == null || usuarios.isEmpty()) { %>
                    <tr><td colspan="5" class="text-muted">No hay cuentas creadas.</td></tr>
                <% } else {
                    for (Usuario u : usuarios) {
                        int completadas = progresoUsuarios == null ? 0 : progresoUsuarios.getOrDefault(u.getId(), 0);
                        int porcentaje = "ESTUDIANTE".equals(u.getRol()) ? Math.min(100, Math.round((completadas * 100f) / total)) : 0;
                %>
                    <tr>
                        <td><%= u.getNombre() %></td>
                        <td><%= u.getCorreo() %></td>
                        <td><span class="badge text-bg-light"><%= u.getRol() %></span></td>
                        <td><span class="badge <%= u.isBloqueado() ? "text-bg-danger" : "text-bg-success" %>"><%= u.isBloqueado() ? "Bloqueado" : "Activo" %></span></td>
                        <td>
                            <% if ("ESTUDIANTE".equals(u.getRol())) { %>
                                <div class="admin-progress-cell">
                                    <span><%= completadas %>/<%= total %></span>
                                    <div class="progress"><div class="progress-bar progress-bar-animated-radix" style="width: <%= porcentaje %>%"></div></div>
                                </div>
                            <% } else { %>
                                <span class="text-muted">No aplica</span>
                            <% } %>
                        </td>
                    </tr>
                <%  }
                   } %>
                </tbody>
            </table>
        </div>
    </section>
    <section class="data-panel admin-panel-accent history-panel">
        <h2 class="h4">Historial de respuestas</h2>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>Estudiante</th>
                    <th>Categoria</th>
                    <th>Puntaje</th>
                    <th>Estado</th>
                    <th>Comentario</th>
                </tr>
                </thead>
                <tbody>
                <% if (actividades == null || actividades.isEmpty()) { %>
                    <tr><td colspan="5" class="text-muted">Aun no hay respuestas registradas.</td></tr>
                <% } else {
                    for (ActividadEstudiante a : actividades) { %>
                        <tr>
                            <td><%= a.getEstudianteNombre() %></td>
                            <td><%= a.getCategoria() %></td>
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
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
