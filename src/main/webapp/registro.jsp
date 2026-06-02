<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
<main class="container py-5 register-shell">
    <div class="row justify-content-center">
        <div class="col-lg-6">
            <section class="auth-panel register-panel">
                <p class="section-kicker">Crear estudiante</p>
                <h1>Registro de estudiante</h1>
                <p class="text-muted">Crea tu cuenta para guardar progreso, avatar y logros.</p>
                <% if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getParameter("error") %></div>
                <% } %>
                <form action="${pageContext.request.contextPath}/registro" method="post" class="needs-validation live-validation-form" data-live-validation novalidate>
                    <div class="mb-3">
                        <label class="form-label" for="nombre">Nombre completo</label>
                        <input class="form-control" type="text" id="nombre" name="nombre" minlength="2" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="correo">Correo</label>
                        <input class="form-control" type="email" id="correo" name="correo" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="clave">Clave</label>
                        <div class="password-shell">
                            <input class="form-control" type="password" id="clave" name="clave" minlength="8" required>
                            <button class="password-toggle" type="button" data-password-toggle="clave" aria-label="Mostrar clave"><span></span></button>
                        </div>
                    </div>
                    <button class="btn btn-radix w-100" type="submit">Crear estudiante</button>
                </form>
                <div class="register-benefits">
                    <span>Progreso guardado</span>
                    <span>Avatar propio</span>
                    <span>Logros desbloqueables</span>
                </div>
            </section>
        </div>
    </div>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/auth-forms.js"></script>
</body>
</html>
