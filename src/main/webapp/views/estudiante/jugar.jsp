<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%
    Integer misionesCompletadas = (Integer) request.getAttribute("misionesCompletadas");
    Integer totalMisiones = (Integer) request.getAttribute("totalMisiones");
    Integer progresoPorcentaje = (Integer) request.getAttribute("progresoPorcentaje");
    List<String> clavesCompletadas = (List<String>) request.getAttribute("clavesCompletadas");
    String claves = clavesCompletadas == null ? "" : String.join(",", clavesCompletadas);
    int total = totalMisiones == null ? 6 : totalMisiones;
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
                    <p>El zorro duplica su energia con cada pocion. Dale 5 pociones y resuelve sus bocados extra.</p>
                    <div class="game-equation"><span id="monsterValue">1</span> x 2 = energia</div>
                    <div class="game-actions">
                        <button class="btn btn-radix" id="feedMonster" type="button">Dar pocion</button>
                        <button class="btn btn-outline-dark" id="resetMonster" type="button">Reiniciar</button>
                    </div>
                    <p class="game-feedback" id="monsterFeedback">Pociones usadas: 0 de 5.</p>
                    <div class="mini-exercises" data-mini-game="monster">
                        <p>Bocados extra</p>
                        <button type="button" data-answer="27" data-options="9,27,30">3^3</button>
                        <button type="button" data-answer="25" data-options="10,20,25">5^2</button>
                    </div>
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
                    <p>Mueve el control y ayuda al panda a construir una torre exacta de 1000 bloques.</p>
                    <div class="game-equation">10^<span id="towerExponent">1</span> = <span id="towerValue">10</span></div>
                    <div class="game-actions">
                        <input class="form-range tower-range" id="towerRange" type="range" min="1" max="4" value="1">
                    </div>
                    <p class="game-feedback" id="towerFeedback">Mueve el control hasta encontrar 10^3.</p>
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
                    <p>El buho ilumina un cuadrado de area 144. Arrastra la regla al borde correcto y resuelve dos sombras.</p>
                    <div class="game-equation">lado x lado = 144</div>
                    <div class="game-actions">
                        <button class="btn btn-outline-dark" id="resetRuler" type="button">Reiniciar regla</button>
                        <button class="btn btn-radix" id="speakRoot" type="button">Escuchar pista</button>
                    </div>
                    <p class="game-feedback" id="laserFeedback">Arrastra la regla roja sobre el borde iluminado.</p>
                    <div class="mini-exercises" data-mini-game="laser">
                        <p>Sombras extra</p>
                        <button type="button" data-answer="9" data-options="6,9,18">raiz de 81</button>
                        <button type="button" data-answer="13" data-options="11,12,13">raiz de 169</button>
                    </div>
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
                    <p>Arrastra el bloque correcto para formar un cubo perfecto de 27. Luego calibra otros cubos.</p>
                    <div class="game-equation">27<sup>1/3</sup> = raiz cubica de 27</div>
                    <p class="game-feedback" id="machineFeedback">Elige el bloque que forma un cubo perfecto de 3 x 3 x 3.</p>
                    <div class="mini-exercises" data-mini-game="machine">
                        <p>Calibraciones extra</p>
                        <button type="button" data-answer="4" data-options="3,4,8">raiz cubica de 64</button>
                        <button type="button" data-answer="5" data-options="5,10,25">raiz cubica de 125</button>
                    </div>
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
                            <p>27 cubos</p>
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
                    <p>Dos portales quieren abrirse. Toca la expresion con mayor energia para ayudar al guia.</p>
                    <div class="game-equation">2^6 vs 6^2</div>
                    <p class="game-feedback" id="compareFeedback">Compara 64 contra 36 antes de tocar un portal.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="comparaciones">
                        <input type="hidden" name="respuesta" value="64>36">
                    </form>
                </div>
                <div class="game-visual portal-visual">
                    <button class="portal-choice" type="button" data-correct="true"><span>2^6</span><strong>64</strong></button>
                    <button class="portal-choice" type="button" data-correct="false"><span>6^2</span><strong>36</strong></button>
                </div>
            </article>

            <article class="game-card memory-card kid-card" id="memoryGame" data-complete-key="memoria=2^3=8;raiz49=7;4^2=16">
                <div class="game-copy">
                    <p class="game-label">Memoria matematica</p>
                    <h2>El Mapa de Pares Secretos</h2>
                    <p>Une cada expresion con su resultado. Las cartas cambian de color cuando haces una pareja.</p>
                    <div class="game-equation">expresion = resultado</div>
                    <p class="game-feedback" id="memoryFeedback">Selecciona una carta de expresion y luego su resultado.</p>
                    <form class="activity-form" action="${pageContext.request.contextPath}/estudiante/actividad" method="post">
                        <input type="hidden" name="categoria" value="memoria">
                        <input type="hidden" name="respuesta" value="2^3=8;raiz49=7;4^2=16">
                    </form>
                </div>
                <div class="game-visual memory-board" id="memoryBoard">
                    <button type="button" data-pair="a">2^3</button>
                    <button type="button" data-pair="b">raiz de 49</button>
                    <button type="button" data-pair="c">4^2</button>
                    <button type="button" data-pair="a">8</button>
                    <button type="button" data-pair="b">7</button>
                    <button type="button" data-pair="c">16</button>
                </div>
            </article>
        </div>
    </section>
</main>
<jsp:include page="/views/shared/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/radix-games.js"></script>
</body>
</html>
