<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Modo invitado | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="guest-shell">
    <section class="guest-hero">
        <div class="container">
            <div class="row align-items-center g-4">
                <div class="col-lg-6">
                    <p class="section-kicker">Modo invitado</p>
                    <h1 class="page-title">Explora EducaRadix antes de registrarte</h1>
                    <p class="lead">Mira categorias, juegos y logros de muestra. Para guardar progreso, elegir avatar y desbloquear logros necesitas crear tu cuenta de estudiante.</p>
                    <div class="guest-hero-actions">
                        <a class="btn btn-radix btn-lg" href="${pageContext.request.contextPath}/registro">Crear estudiante</a>
                        <a class="btn btn-outline-dark btn-lg" href="${pageContext.request.contextPath}/login">Iniciar sesion</a>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="guest-preview-board">
                        <div class="guest-score-card">
                            <span>Vista limitada</span>
                            <strong>0/7</strong>
                            <p>El progreso se activa al registrarte.</p>
                        </div>
                        <div class="animal-playground guest-animals" aria-hidden="true">
                            <div class="animal-face fox-face"><span></span></div>
                            <div class="animal-face owl-face"><span></span></div>
                            <div class="animal-face panda-face"><span></span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="container guest-create-band">
        <div class="guest-create-card">
            <p class="section-kicker mb-1">Cuenta de estudiante</p>
            <h2>Guarda tus avances y juega completo</h2>
            <p>Con una cuenta puedes completar los 7 juegos, reiniciar misiones, ver tu barra de progreso, personalizar avatar y desbloquear logros.</p>
            <a class="btn btn-radix" href="${pageContext.request.contextPath}/registro">Crear estudiante</a>
        </div>
    </section>

    <section class="container content-band pt-2">
        <div class="guest-section-title">
            <p class="section-kicker">Lo que ofrecemos</p>
            <h2>Un vistazo al apartado de estudiantes</h2>
        </div>
        <div class="guest-offer-grid">
            <article class="guest-offer-card">
                <span class="feature-symbol">a<sup>n</sup></span>
                <h3>Potencias</h3>
                <p>Explora juegos como el zorro 3D y la torre del panda para practicar multiplicacion repetida.</p>
            </article>
            <article class="guest-offer-card">
                <span class="feature-symbol">&radic;x</span>
                <h3>Raices</h3>
                <p>Conoce retos de cuadrados, cubos y bases escondidas con pistas visuales.</p>
            </article>
            <article class="guest-offer-card">
                <span class="feature-symbol">OK</span>
                <h3>Logros y perfil</h3>
                <p>Al registrarte veras logros, progreso por juego, avatar y resumen de aprendizaje.</p>
            </article>
        </div>
    </section>

    <section class="container pb-5">
        <div class="guest-section-title">
            <p class="section-kicker">Juegos de muestra</p>
            <h2>Disponible completo al crear cuenta</h2>
        </div>
        <div class="guest-game-grid">
            <article class="guest-game-card">
                <div class="category-animal fox-mini"><span></span></div>
                <h3>Alimentador del Zorro</h3>
                <p>Potencias con 8 ejercicios aleatorios.</p>
                <span>Necesita cuenta para guardar</span>
            </article>
            <article class="guest-game-card">
                <div class="category-animal panda-mini"><span></span></div>
                <h3>Torre del Panda</h3>
                <p>Construye torres con potencias de 10.</p>
                <span>Necesita cuenta para guardar</span>
            </article>
            <article class="guest-game-card">
                <div class="category-animal owl-mini"><span></span></div>
                <h3>Pares Secretos</h3>
                <p>Une expresiones con resultados y sube niveles.</p>
                <span>Necesita cuenta para guardar</span>
            </article>
        </div>
    </section>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
