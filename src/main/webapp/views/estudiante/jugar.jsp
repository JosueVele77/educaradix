<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%
    Integer misionesCompletadas = (Integer) request.getAttribute("misionesCompletadas");
    Integer totalMisiones = (Integer) request.getAttribute("totalMisiones");
    Integer progresoPorcentaje = (Integer) request.getAttribute("progresoPorcentaje");
    List<String> clavesCompletadas = (List<String>) request.getAttribute("clavesCompletadas");
    String claves = clavesCompletadas == null ? "" : String.join(",", clavesCompletadas);
    int total = totalMisiones == null ? 7 : totalMisiones;
    int completadas = misionesCompletadas == null ? 0 : misionesCompletadas;
    int porcentaje = progresoPorcentaje == null ? 0 : progresoPorcentaje;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Jugar | EducaRadix</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
<jsp:include page="/views/shared/navbar.jsp"/>
<main class="game-shell" data-context="${pageContext.request.contextPath}" data-total-missions="<%= total %>" data-completed-keys="<%= claves %>">
    <section class="game-hero play-hero">
        <div class="container">
            <div class="row align-items-center g-4">
                <div class="col-lg-6">
                    <p class="section-kicker">Apartado jugar</p>
                    <h1 class="page-title">Elige, prueba y completa misiones</h1>
                    <p class="lead">Juegos de potencias, raices y retos mixtos con animales guia, botones grandes y actividades para tocar, arrastrar y descubrir.</p>
                    <div class="mission-status">
                        <span><strong id="missionCount"><%= completadas %></strong>/<%= total %> misiones completadas</span>
                        <div class="progress">
                            <div id="missionProgress" class="progress-bar" style="width: <%= porcentaje %>%"></div>
                        </div>
                    </div>
                    <div id="successToast" class="success-toast" role="status" aria-live="polite"></div>
                    <div class="hero-actions">
                        <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/estudiante/categorias">Ver categorias</a>
                        <a class="btn btn-radix" href="#juegos-potencias">Empezar</a>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="animal-playground" aria-label="Animales guia de EducaRadix">
                        <div class="animal-face fox-face"><span></span></div>
                        <div class="animal-face owl-face"><span></span></div>
                        <div class="animal-face panda-face"><span></span></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="container play-directory py-4" aria-label="Tipos de juegos">
        <a href="#juegos-potencias"><strong>Potencias</strong><span>Monstruo y torre</span></a>
        <a href="#juegos-raices"><strong>Raices</strong><span>Sombra y maquina</span></a>
        <a href="#juegos-retos"><strong>Retos mixtos</strong><span>Portales y memoria</span></a>
    </section>

    <section class="container game-category-section" id="juegos-potencias">
        <div class="game-section-heading">
            <p class="section-kicker">Juegos de potencias</p>
            <h2>Multiplica poderes</h2>
        </div>
        <div class="game-grid">
            <article class="game-card monster-card kid-card" id="monsterGame" data-complete-key="potencias=32">
                <div class="game-copy">
                    <p class="game-label">Potencias - 2^5</p>
                    <h2>El Alimentador del Zorro 3D</h2>
                    <p>El zorro gana energia con cada pocion. Completa 8 rondas cambiando base y exponente.</p>
                    <div class="game-equation"><span id="monsterValue">1</span> x <span id="monsterBase">2</span> = energia</div>
                    <div class="level-pill">Ronda <span id="monsterRound">1</span> de 8: <strong id="monsterGoal">2<sup>5</sup></strong></div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="monsterProgress"></div></div>
                    </div>
                    <div class="game-actions">
                        <button class="btn btn-radix" id="feedMonster" type="button">Dar pocion</button>
                        <button class="btn btn-outline-dark" id="resetMonster" type="button">Reiniciar</button>
                    </div>
                    <p class="game-feedback" id="monsterFeedback">Pociones usadas: 0 de 5.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="potencias">
                        <input type="hidden" name="respuesta" value="32">
                    </form>
                </div>
                <div class="game-visual">
                    <div id="monsterStage" class="monster-stage"></div>
                    <div class="potion-row" aria-hidden="true">
                        <span></span><span></span><span></span><span></span><span></span>
                    </div>
                </div>
            </article>

            <article class="game-card tower-card kid-card" id="towerGame" data-complete-key="torre=1000">
                <div class="game-copy">
                    <p class="game-label">Potencias de 10</p>
                    <h2>La Torre del Panda</h2>
                    <p>Mueve el control y ayuda al panda a construir torres exactas. Completa 8 torres.</p>
                    <div class="game-equation">10^<span id="towerExponent">1</span> = <span id="towerValue">10</span></div>
                    <div class="level-pill">Torre <span id="towerLevel">1</span> de 8: meta <strong id="towerTarget">100</strong></div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="towerProgress"></div></div>
                    </div>
                    <div class="game-actions">
                        <input class="form-range tower-range" id="towerRange" type="range" min="1" max="5" value="1">
                    </div>
                    <p class="game-feedback" id="towerFeedback">Mueve el control hasta encontrar la meta.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="torre">
                        <input type="hidden" name="respuesta" value="1000">
                    </form>
                </div>
                <div class="game-visual tower-visual">
                    <div class="tower-mascot panda-mini" aria-hidden="true"><span></span></div>
                    <div class="tower-stack" id="towerStack"><span></span></div>
                </div>
            </article>
        </div>
    </section>

    <section class="container game-category-section" id="juegos-raices">
        <div class="game-section-heading">
            <p class="section-kicker">Juegos de raices</p>
            <h2>Encuentra el lado oculto</h2>
        </div>
        <div class="game-grid">
            <article class="game-card laser-card kid-card" id="laserGame" data-complete-key="raices=12">
                <div class="game-copy">
                    <p class="game-label">Raices cuadradas - raiz de 144</p>
                    <h2>La Sombra Laser del Buho</h2>
                    <p>El buho ilumina cuadrados distintos. Arrastra la regla al borde correcto en cada ronda.</p>
                    <div class="game-equation">lado x lado = <span id="laserArea">144</span></div>
                    <div class="level-pill">Sombra <span id="laserRound">1</span> de 8</div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="laserProgress"></div></div>
                    </div>
                    <div class="game-actions">
                        <button class="btn btn-outline-dark" id="resetRuler" type="button">Reiniciar regla</button>
                        <button class="btn btn-radix" id="speakRoot" type="button">Escuchar pista</button>
                    </div>
                    <p class="game-feedback" id="laserFeedback">Arrastra la regla roja sobre el borde iluminado.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="raices">
                        <input type="hidden" name="respuesta" value="12">
                    </form>
                </div>
                <div class="game-visual">
                    <canvas id="laserCanvas" class="laser-canvas" width="620" height="430"></canvas>
                </div>
            </article>

            <article class="game-card machine-card kid-card" id="machineGame" data-complete-key="radicales=3">
                <div class="game-copy">
                    <p class="game-label">Raices cubicas - 27^(1/3)</p>
                    <h2>La Maquina de Cubos del Conejo</h2>
                    <p>Arrastra el bloque correcto para formar cubos perfectos. Cada ronda cambia la energia.</p>
                    <div class="game-equation"><span id="machineTarget">27</span><sup>1/3</sup> = &#8731;<span id="machineTargetCopy">27</span></div>
                    <div class="level-pill">Cubo <span id="machineRound">1</span> de 8</div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="machineProgress"></div></div>
                    </div>
                    <p class="game-feedback" id="machineFeedback">Elige el bloque que forma un cubo perfecto de 3 x 3 x 3.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="radicales">
                        <input type="hidden" name="respuesta" value="3">
                    </form>
                </div>
                <div class="game-visual machine-visual">
                    <div class="robot-video">
                        <div class="robot-head"><span></span><span></span></div>
                        <div class="robot-body">
                            <div class="energy-cubes"></div>
                            <p><span id="machineCubeCount">27</span> cubos</p>
                        </div>
                    </div>
                    <div id="machineDrop" class="machine-drop">Suelta aqui</div>
                    <div class="block-options">
                        <button class="block-chip" draggable="true" data-value="3" type="button">Bloque 3</button>
                        <button class="block-chip" draggable="true" data-value="9" type="button">Bloque 9</button>
                        <button class="block-chip" draggable="true" data-value="2" type="button">Bloque 2</button>
                    </div>
                </div>
            </article>
        </div>
    </section>

    <section class="container game-category-section pb-4" id="juegos-retos">
        <div class="game-section-heading">
            <p class="section-kicker">Retos mixtos</p>
            <h2>Decide, une y celebra</h2>
        </div>
        <div class="game-grid">
            <article class="game-card compare-card kid-card" id="compareGame" data-complete-key="comparaciones=64>36">
                <div class="game-copy">
                    <p class="game-label">Comparacion de potencias</p>
                    <h2>El Portal de Mayor Poder</h2>
                    <p>Dos portales quieren abrirse. Toca la expresion con mayor energia en cada ronda.</p>
                    <div class="game-equation" id="compareEquation">2<sup>6</sup> vs 6<sup>2</sup></div>
                    <div class="level-pill">Ronda <span id="compareRound">1</span> de 8</div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="compareProgress"></div></div>
                    </div>
                    <p class="game-feedback" id="compareFeedback">Compara 64 contra 36 antes de tocar un portal.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="comparaciones">
                        <input type="hidden" name="respuesta" value="64>36">
                    </form>
                </div>
                <div class="game-visual portal-visual">
                    <button class="portal-choice" type="button"><span>2<sup>6</sup></span><strong>64</strong></button>
                    <button class="portal-choice" type="button"><span>6<sup>2</sup></span><strong>36</strong></button>
                </div>
            </article>

            <article class="game-card memory-card kid-card" id="memoryGame" data-complete-key="memoria=2^3=8;raiz49=7;4^2=16">
                <div class="game-copy">
                    <p class="game-label">Memoria matematica</p>
                    <h2>El Mapa de Pares Secretos</h2>
                    <p>Une cada expresion con su resultado. Sube hasta el nivel 10 con pares nuevos.</p>
                    <div class="game-equation">expresion = resultado</div>
                    <div class="level-pill">Nivel <span id="memoryLevel">1</span> de 10</div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="memoryProgress"></div></div>
                    </div>
                    <p class="game-feedback" id="memoryFeedback">Selecciona una carta de expresion y luego su resultado.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="memoria">
                        <input type="hidden" name="respuesta" value="2^3=8;raiz49=7;4^2=16">
                    </form>
                </div>
                <div class="game-visual memory-board" id="memoryBoard">
                </div>
            </article>

            <article class="game-card lake-card kid-card" id="lakeGame" data-complete-key="laguna=2">
                <div class="game-copy">
                    <p class="game-label">Bases escondidas</p>
                    <h2>La Laguna de los Peces</h2>
                    <p>El lago muestra un resultado. Pesca el numero que multiplicado por si mismo las veces indicadas forma ese resultado.</p>
                    <div class="game-equation"><span id="lakeBaseHint">? x ? x ?</span> = <span id="lakeTarget">8</span></div>
                    <div class="level-pill">Pez <span id="lakeRound">1</span> de 8</div>
                    <div class="game-local-progress">
                        <span>Progreso del juego</span>
                        <div class="progress"><div class="progress-bar" id="lakeProgress"></div></div>
                    </div>
                    <p class="game-feedback" id="lakeFeedback">Busca el pez con el numero 2.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="laguna">
                        <input type="hidden" name="respuesta" value="2">
                    </form>
                </div>
                <div class="game-visual lake-visual" id="lakeVisual">
                    <div class="lake-water" data-target="8">
                        <button class="fish fish-a" type="button"></button>
                        <button class="fish fish-b" type="button"></button>
                        <button class="fish fish-c" type="button"></button>
                        <button class="fish fish-d" type="button"></button>
                    </div>
                </div>
            </article>
        </div>
    </section>
    <div id="gameSignal" class="game-signal" aria-live="polite" aria-hidden="true"></div>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/radix-games.js"></script>
</body>
</html>
