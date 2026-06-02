<%@ page import="io.github.josuevele77.educaradix.models.Usuario" %>
<%
    Usuario usuarioNav = (Usuario) session.getAttribute("usuario");
    String ctxNav = request.getContextPath();
    String avatarNav = usuarioNav != null ? usuarioNav.getAvatarUrl() : null;
    boolean tieneAvatarNav = avatarNav != null && !avatarNav.trim().isEmpty();
%>
<nav class="navbar navbar-expand-lg radix-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2" href="<%= ctxNav %>/index.jsp">
            <img src="<%= ctxNav %>/assets/img/logo-radix.svg" alt="EducaRadix" width="42" height="42">
            <span>EducaRadix</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarRadix"
                aria-controls="navbarRadix" aria-expanded="false" aria-label="Menu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarRadix">
            <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-2">
                <li class="nav-item"><a class="nav-link" href="<%= usuarioNav == null ? ctxNav + "/invitado" : ctxNav + "/index.jsp" %>">Inicio</a></li>
                <% if (usuarioNav == null) { %>
                    <li class="nav-item"><a class="nav-link" href="<%= ctxNav %>/registro">Crear cuenta</a></li>
                <% } %>
                <% if (usuarioNav != null && "ADMIN".equals(usuarioNav.getRol())) { %>
                    <li class="nav-item"><a class="nav-link" href="<%= ctxNav %>/admin/dashboard">Panel</a></li>
                    <li class="nav-item"><a class="nav-link" href="<%= ctxNav %>/admin/usuarios">Usuarios</a></li>
                    <li class="nav-item"><a class="nav-link" href="<%= ctxNav %>/admin/bitacora">Bitacora</a></li>
                <% } else if (usuarioNav != null && "ESTUDIANTE".equals(usuarioNav.getRol())) { %>
                    <li class="nav-item"><a class="nav-link" href="<%= ctxNav %>/estudiante/categorias">Categorias</a></li>
                    <li class="nav-item"><a class="nav-link" href="<%= ctxNav %>/estudiante/jugar">Jugar</a></li>
                <% } %>
                <% if (usuarioNav == null) { %>
                    <li class="nav-item"><a class="btn btn-radix" href="<%= ctxNav %>/login">Ingresar</a></li>
                <% } else { %>
                    <li class="nav-item dropdown account-menu">
                        <button class="nav-link account-toggle dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <span class="avatar-ring">
                                <% if (tieneAvatarNav) { %>
                                    <img src="<%= avatarNav %>" alt="Avatar de <%= usuarioNav.getNombre() %>">
                                <% } else { %>
                                    <span><%= usuarioNav.getNombre() != null && !usuarioNav.getNombre().isEmpty() ? usuarioNav.getNombre().substring(0, 1).toUpperCase() : "U" %></span>
                                <% } %>
                            </span>
                            <span class="account-name"><%= usuarioNav.getNombre() %></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end account-dropdown">
                            <% if ("ESTUDIANTE".equals(usuarioNav.getRol())) { %>
                                <li><a class="dropdown-item" href="<%= ctxNav %>/estudiante/perfil">Perfil</a></li>
                                <li><a class="dropdown-item" href="<%= ctxNav %>/estudiante/perfil#ajustes">Ajustes</a></li>
                            <% } else { %>
                                <li><a class="dropdown-item" href="<%= ctxNav %>/admin/dashboard">Panel</a></li>
                                <li><a class="dropdown-item" href="<%= ctxNav %>/admin/usuarios">Usuarios</a></li>
                            <% } %>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger fw-bold" href="<%= ctxNav %>/logout">Cerrar sesion</a></li>
                        </ul>
                    </li>
                <% } %>
                <li class="nav-item">
                    <button class="theme-toggle" id="themeToggle" type="button" aria-label="Cambiar modo claro u oscuro">
                        <span class="theme-toggle-icon" aria-hidden="true"></span>
                        <span id="themeToggleText">Modo</span>
                    </button>
                </li>
            </ul>
        </div>
    </div>
</nav>
<script>
    (function () {
        var root = document.documentElement;
        var saved = localStorage.getItem("educaradix-theme") || "light";
        var button = document.getElementById("themeToggle");
        var label = document.getElementById("themeToggleText");
        function applyTheme(theme) {
            root.setAttribute("data-theme", theme);
            if (label) {
                label.textContent = theme === "dark" ? "Oscuro" : "Claro";
            }
            if (button) {
                button.setAttribute("aria-pressed", theme === "dark" ? "true" : "false");
            }
        }
        applyTheme(saved);
        if (button) {
            button.addEventListener("click", function () {
                var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
                localStorage.setItem("educaradix-theme", next);
                applyTheme(next);
            });
        }
    }());
</script>
