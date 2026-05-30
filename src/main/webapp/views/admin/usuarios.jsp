<%@ page import="java.util.List" %>
<%@ page import="io.github.josuevele77.educaradix.models.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Usuarios | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="container py-4">
    <p class="section-kicker">Administrador</p>
    <h1 class="page-title">Gestion de usuarios</h1>
    <section class="data-panel mb-4">
        <h2 class="h4">Ingresar nuevo usuario</h2>
        <form class="row g-3" action="${pageContext.request.contextPath}/admin/usuarios" method="post">
            <input type="hidden" name="accion" value="crear">
            <div class="col-md-3"><input class="form-control" name="nombre" placeholder="Nombre" required></div>
            <div class="col-md-3"><input class="form-control" type="email" name="correo" placeholder="correo@dominio.com" required></div>
            <div class="col-md-2"><input class="form-control" type="password" name="clave" minlength="8" placeholder="Clave" required></div>
            <div class="col-md-2">
                <select class="form-select" name="rol">
                    <option value="ESTUDIANTE">Estudiante</option>
                    <option value="ADMIN">Administrador</option>
                </select>
            </div>
            <div class="col-md-2"><button class="btn btn-radix w-100" type="submit">Guardar</button></div>
        </form>
    </section>
    <section class="data-panel">
        <h2 class="h4">Consultar y actualizar usuarios</h2>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Rol</th>
                    <th>Clave nueva</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
                </thead>
                <tbody>
                <% if (usuarios != null) {
                    for (Usuario u : usuarios) { %>
                        <tr>
                            <form action="${pageContext.request.contextPath}/admin/usuarios" method="post">
                                <input type="hidden" name="accion" value="actualizar">
                                <input type="hidden" name="id" value="<%= u.getId() %>">
                                <input type="hidden" name="bloqueadoActual" value="<%= u.isBloqueado() %>">
                                <td><%= u.getId() %></td>
                                <td><input class="form-control form-control-sm" name="nombre" value="<%= u.getNombre() %>" required></td>
                                <td><input class="form-control form-control-sm" type="email" name="correo" value="<%= u.getCorreo() %>" required></td>
                                <td>
                                    <select class="form-select form-select-sm" name="rol">
                                        <option value="ESTUDIANTE" <%= "ESTUDIANTE".equals(u.getRol()) ? "selected" : "" %>>Estudiante</option>
                                        <option value="ADMIN" <%= "ADMIN".equals(u.getRol()) ? "selected" : "" %>>Administrador</option>
                                    </select>
                                </td>
                                <td><input class="form-control form-control-sm" type="password" name="clave" minlength="8" placeholder="Opcional"></td>
                                <td><span class="badge <%= u.isBloqueado() ? "text-bg-danger" : "text-bg-success" %>"><%= u.isBloqueado() ? "Bloqueado" : "Activo" %></span></td>
                                <td class="d-flex flex-wrap gap-2">
                                    <button class="btn btn-outline-dark btn-sm" type="submit">Actualizar</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/admin/usuarios" method="post">
                                <input type="hidden" name="accion" value="bloquear">
                                <input type="hidden" name="id" value="<%= u.getId() %>">
                                <input type="hidden" name="bloqueado" value="<%= !u.isBloqueado() %>">
                                <button class="btn <%= u.isBloqueado() ? "btn-success" : "btn-outline-danger" %> btn-sm" type="submit">
                                    <%= u.isBloqueado() ? "Desbloquear" : "Bloquear" %>
                                </button>
                            </form>
                                </td>
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
