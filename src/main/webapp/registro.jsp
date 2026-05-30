<%@ page import="java.util.List" %>
<%@ page import="io.github.josuevele77.educaradix.models.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Usuario> usuariosPublicos = (List<Usuario>) request.getAttribute("usuariosPublicos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registro | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="container py-5">
    <div class="row g-4 align-items-start">
        <div class="col-lg-5">
            <section class="auth-panel">
                <h1>Registro de estudiante</h1>
                <p class="text-muted">El correo debe ser valido y la clave debe tener minimo 8 caracteres.</p>
                <% if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getParameter("error") %></div>
                <% } %>
                <form action="${pageContext.request.contextPath}/registro" method="post" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label class="form-label" for="nombre">Nombre completo</label>
                        <input class="form-control" type="text" id="nombre" name="nombre" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="correo">Correo</label>
                        <input class="form-control" type="email" id="correo" name="correo" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="clave">Clave</label>
                        <input class="form-control" type="password" id="clave" name="clave" minlength="8" required>
                    </div>
                    <button class="btn btn-radix w-100" type="submit">Crear cuenta</button>
                </form>
            </section>
        </div>
        <div class="col-lg-7">
            <section class="data-panel">
                <div class="d-flex align-items-center justify-content-between gap-3 mb-3">
                    <div>
                        <p class="section-kicker mb-1">Vista invitado</p>
                        <h2 class="h4 mb-0">Usuarios registrados</h2>
                    </div>
                    <a class="btn btn-outline-dark btn-sm" href="${pageContext.request.contextPath}/invitado/usuarios">Actualizar</a>
                </div>
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                        <tr>
                            <th>Nombre</th>
                            <th>Correo</th>
                            <th>Rol</th>
                            <th>Estado</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% if (usuariosPublicos == null || usuariosPublicos.isEmpty()) { %>
                            <tr><td colspan="4" class="text-muted">Usa el enlace Invitado para consultar los registros visibles.</td></tr>
                        <% } else {
                            for (Usuario u : usuariosPublicos) { %>
                                <tr>
                                    <td><%= u.getNombre() %></td>
                                    <td><%= u.getCorreo() %></td>
                                    <td><span class="badge text-bg-light"><%= u.getRol() %></span></td>
                                    <td><%= u.isBloqueado() ? "Bloqueado" : "Activo" %></td>
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
