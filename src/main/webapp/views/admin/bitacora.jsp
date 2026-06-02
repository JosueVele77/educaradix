<%@ page import="java.util.List" %>
<%@ page import="io.github.josuevele77.educaradix.models.Bitacora" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Bitacora> bitacora = (List<Bitacora>) request.getAttribute("bitacora");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bitacora | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="container py-4 admin-shell">
    <div class="admin-title-row">
        <div>
            <p class="section-kicker">Administrador</p>
            <h1 class="page-title">Bitacora del sistema</h1>
        </div>
        <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/admin/dashboard">Volver al panel</a>
    </div>
    <section class="data-panel admin-panel-accent log-panel">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-3">
            <div>
                <p class="section-kicker mb-1">Actividad</p>
                <h2 class="h4 mb-0">Eventos recientes</h2>
            </div>
            <span class="admin-soft-badge">Ultimos 200 registros</span>
        </div>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Usuario</th>
                    <th>Accion</th>
                    <th>Detalle</th>
                </tr>
                </thead>
                <tbody>
                <% if (bitacora == null || bitacora.isEmpty()) { %>
                    <tr><td colspan="4" class="text-muted">No hay eventos registrados.</td></tr>
                <% } else {
                    for (Bitacora b : bitacora) { %>
                        <tr>
                            <td><%= b.getFecha() %></td>
                            <td><%= b.getUsuarioNombre() %></td>
                            <td><span class="badge text-bg-light"><%= b.getAccion() %></span></td>
                            <td><%= b.getDetalle() %></td>
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
