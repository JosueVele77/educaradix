<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="io.github.josuevele77.educaradix.models.Usuario" %>
<%
    Usuario usuarioInicio = (Usuario) session.getAttribute("usuario");
    if (usuarioInicio == null) {
        response.sendRedirect(request.getContextPath() + "/invitado");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>EducaRadix | Potencias y raices</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main>
    <section class="hero-radix">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6">
                    <p class="section-kicker">Matematica interactiva</p>
                    <h1>EducaRadix</h1>
                    <p class="lead">Aprende potencias, raices y exponentes fraccionarios con ejercicios, multimedia y un modelo 3D que conecta la base, el exponente y el resultado.</p>
                    <div class="d-flex flex-wrap gap-2">
                        <% if (usuarioInicio == null) { %>
                            <a class="btn btn-radix btn-lg" href="${pageContext.request.contextPath}/registro">Crear cuenta</a>
                            <a class="btn btn-outline-dark btn-lg" href="${pageContext.request.contextPath}/login">Ingresar</a>
                        <% } else if ("ESTUDIANTE".equals(usuarioInicio.getRol())) { %>
                            <a class="btn btn-radix btn-lg" href="${pageContext.request.contextPath}/estudiante/jugar">Ir a jugar</a>
                            <a class="btn btn-outline-dark btn-lg" href="${pageContext.request.contextPath}/estudiante/perfil">Ver perfil</a>
                        <% } else { %>
                            <a class="btn btn-radix btn-lg" href="${pageContext.request.contextPath}/admin/dashboard">Ir al panel</a>
                        <% } %>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="formula-board">
                        <img src="${pageContext.request.contextPath}/assets/img/power-root-hero.svg" alt="Diagrama de potencias y raices" class="img-fluid">
                    </div>
                </div>
            </div>
        </div>
    </section>
    <section class="content-band">
        <div class="container">
            <div class="row g-4">
                <div class="col-md-4">
                    <article class="feature-card">
                        <span class="feature-symbol">a<sup>n</sup></span>
                        <h2>Potencias</h2>
                        <p>Comprende como una base crece al multiplicarse repetidamente por si misma.</p>
                    </article>
                </div>
                <div class="col-md-4">
                    <article class="feature-card">
                        <span class="feature-symbol">&radic;x</span>
                        <h2>Raices</h2>
                        <p>Relaciona cada raiz con la pregunta: que numero produce este valor al elevarlo?</p>
                    </article>
                </div>
                <div class="col-md-4">
                    <article class="feature-card">
                        <span class="feature-symbol">x<sup>1/n</sup></span>
                        <h2>Radicales</h2>
                        <p>Conecta raices y exponentes racionales para simplificar expresiones.</p>
                    </article>
                </div>
            </div>
        </div>
    </section>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
