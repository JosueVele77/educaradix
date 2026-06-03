package io.github.josuevele77.educaradix.controllers;

import io.github.josuevele77.educaradix.models.Usuario;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        Usuario usuario = session != null ? (Usuario) session.getAttribute("usuario") : null;

        if (usuario == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=Debes iniciar sesion.");
            return;
        }

        if (usuario.isBloqueado()) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?error=Tu usuario esta bloqueado.");
            return;
        }

        String uri = req.getRequestURI();
        if (uri.contains("/admin/") && !"ADMIN".equals(usuario.getRol())) {
            resp.sendRedirect(req.getContextPath() + "/estudiante/categorias");
            return;
        }

        if (uri.contains("/estudiante/") && !"ESTUDIANTE".equals(usuario.getRol())) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        chain.doFilter(request, response);
    }
}
