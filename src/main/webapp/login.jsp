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
    <div class="row justify-content-center g-4 align-items-stretch">
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
                <form action="${pageContext.request.contextPath}/login" method="post" class="needs-validation live-validation-form" data-live-validation novalidate>
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
                    <button class="btn btn-radix w-100" type="submit">Entrar</button>
                </form>
                <p class="mt-3 mb-0 small">Admin inicial: admin@educaradix.edu / Admin1234</p>
            </section>
        </div>
        <div class="col-lg-5">
            <section class="auth-panel create-account-panel h-100">
                <p class="section-kicker">Cuenta nueva</p>
                <h1>Crear cuenta</h1>
                <p class="text-muted">Los estudiantes pueden registrarse y empezar a guardar su progreso, avatar y logros desbloqueados.</p>
                <div class="create-account-steps">
                    <span>1</span><strong>Ingresa tu nombre y correo.</strong>
                    <span>2</span><strong>Elige una clave segura.</strong>
                    <span>3</span><strong>Entra a Jugar y completa misiones.</strong>
                </div>
                <a class="btn btn-radix w-100 mt-3" href="${pageContext.request.contextPath}/registro">Ir a crear cuenta</a>
            </section>
        </div>
    </div>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/auth-forms.js"></script>
</body>
</html>
