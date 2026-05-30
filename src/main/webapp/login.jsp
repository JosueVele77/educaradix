<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ingresar | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body class="auth-page">
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-5">
            <section class="auth-panel">
                <h1>Ingresar</h1>
                <p class="text-muted">Accede como administrador o estudiante para continuar.</p>
                <% if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getParameter("error") %></div>
                <% } %>
                <% if (request.getParameter("mensaje") != null) { %>
                    <div class="alert alert-success"><%= request.getParameter("mensaje") %></div>
                <% } %>
                <form action="${pageContext.request.contextPath}/login" method="post" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label class="form-label" for="correo">Correo</label>
                        <input class="form-control" type="email" id="correo" name="correo" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="clave">Clave</label>
                        <input class="form-control" type="password" id="clave" name="clave" minlength="8" required>
                    </div>
                    <button class="btn btn-radix w-100" type="submit">Entrar</button>
                </form>
                <p class="mt-3 mb-0 small">Admin inicial: admin@educaradix.edu / Admin1234</p>
            </section>
        </div>
    </div>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
