<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer misionesCompletadas = (Integer) request.getAttribute("misionesCompletadas");
    Integer totalMisiones = (Integer) request.getAttribute("totalMisiones");
    Integer progresoPorcentaje = (Integer) request.getAttribute("progresoPorcentaje");
    int total = totalMisiones == null ? 7 : totalMisiones;
    int completadas = misionesCompletadas == null ? 0 : misionesCompletadas;
    int porcentaje = progresoPorcentaje == null ? 0 : progresoPorcentaje;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Categorias | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="category-shell">
    <section class="category-hero">
        <div class="container">
            <div class="row align-items-center g-4">
                <div class="col-lg-7">
                    <p class="section-kicker">Categorias</p>
                    <h1 class="page-title">Escoge que quieres practicar</h1>
                    <p class="lead">Cada categoria agrupa juegos del mismo tema. Cuando quieras ver todo junto, entra al apartado Jugar.</p>
                    <div class="mission-status">
                        <span><strong><%= completadas %></strong>/<%= total %> misiones completadas</span>
                        <div class="progress">
                            <div class="progress-bar" style="width: <%= porcentaje %>%"></div>
                        </div>
                    </div>
                    <div class="hero-actions">
                        <a class="btn btn-radix" href="${pageContext.request.contextPath}/estudiante/jugar">Jugar todo</a>
                        <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/estudiante/perfil">Ver progreso</a>
                    </div>
                </div>
                <div class="col-lg-5">
                    <div class="category-mascot-board" aria-hidden="true">
                        <div class="animal-face fox-face"><span></span></div>
                        <div class="animal-face owl-face"><span></span></div>
                        <div class="animal-face panda-face"><span></span></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="container category-select-grid py-4">
        <article class="category-tile power-tile">
            <div class="category-animal fox-mini" aria-hidden="true"><span></span></div>
            <div>
                <p class="game-label">Potencias</p>
                <h2>Juegos de potencias</h2>
                <p>Practica bases, exponentes, duplicaciones y potencias de 10.</p>
            </div>
            <a class="btn btn-radix" href="${pageContext.request.contextPath}/estudiante/jugar#juegos-potencias">Jugar potencias</a>
        </article>

        <article class="category-tile root-tile">
            <div class="category-animal owl-mini" aria-hidden="true"><span></span></div>
            <div>
                <p class="game-label">Raices</p>
                <h2>Juegos de raices</h2>
                <p>Encuentra lados ocultos, raices cuadradas y raices cubicas.</p>
            </div>
            <a class="btn btn-radix" href="${pageContext.request.contextPath}/estudiante/jugar#juegos-raices">Jugar raices</a>
        </article>

        <article class="category-tile mixed-tile">
            <div class="category-animal panda-mini" aria-hidden="true"><span></span></div>
            <div>
                <p class="game-label">Retos mixtos</p>
                <h2>Memoria y comparaciones</h2>
                <p>Compara potencias, une expresiones y pesca bases escondidas.</p>
            </div>
            <a class="btn btn-radix" href="${pageContext.request.contextPath}/estudiante/jugar#juegos-retos">Jugar retos</a>
        </article>
    </section>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
