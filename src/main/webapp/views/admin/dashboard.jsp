<%@ page import="java.util.List" %>
<%@ page import="io.github.josuevele77.educaradix.models.ActividadEstudiante" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<ActividadEstudiante> pendientes = (List<ActividadEstudiante>) request.getAttribute("pendientes");
    List<ActividadEstudiante> actividades = (List<ActividadEstudiante>) request.getAttribute("actividades");
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
<main class="container py-4">
    <p class="section-kicker">Administrador</p>
    <h1 class="page-title">Panel de control</h1>
    <div class="row g-3 mb-4">
        <div class="col-md-3"><div class="metric-card"><span>Estudiantes</span><strong><%= request.getAttribute("totalEstudiantes") %></strong></div></div>
        <div class="col-md-3"><div class="metric-card"><span>Administradores</span><strong><%= request.getAttribute("totalAdmins") %></strong></div></div>
        <div class="col-md-3"><div class="metric-card"><span>Bloqueados</span><strong><%= request.getAttribute("totalBloqueados") %></strong></div></div>
        <div class="col-md-3"><div class="metric-card"><span>Por revisar</span><strong><%= request.getAttribute("actividadesPendientes") %></strong></div></div>
    </div>
    <section class="data-panel mb-4">
        <h2 class="h4">Actividades pendientes</h2>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>Estudiante</th>
                    <th>Categoria</th>
                    <th>Respuesta</th>
                    <th>Puntaje</th>
                    <th>Revision</th>
                </tr>
                </thead>
                <tbody>
                <% if (pendientes == null || pendientes.isEmpty()) { %>
                    <tr><td colspan="5" class="text-muted">No hay actividades pendientes.</td></tr>
                <% } else {
                    for (ActividadEstudiante a : pendientes) { %>
                        <tr>
                            <td><%= a.getEstudianteNombre() %></td>
                            <td><%= a.getCategoria() %></td>
                            <td><%= a.getRespuesta() %></td>
                            <td><%= a.getPuntaje() %></td>
                            <td>
                                <form class="d-flex flex-wrap gap-2" action="${pageContext.request.contextPath}/admin/actividades" method="post">
                                    <input type="hidden" name="id" value="<%= a.getId() %>">
                                    <input class="form-control form-control-sm review-input" type="text" name="comentario" placeholder="Comentario">
                                    <button class="btn btn-success btn-sm" name="aprobado" value="true" type="submit">Aprobar</button>
                                    <button class="btn btn-outline-danger btn-sm" name="aprobado" value="false" type="submit">Observar</button>
                                </form>
                            </td>
                        </tr>
                <%  }
                   } %>
                </tbody>
            </table>
        </div>
    </section>
    <section class="data-panel">
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
