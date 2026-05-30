package io.github.josuevele77.educaradix.controllers;

import io.github.josuevele77.educaradix.dao.UsuarioDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/invitado/usuarios")
public class VisitanteController extends HttpServlet {
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("usuariosPublicos", usuarioDAO.listarPublicos());
        request.setAttribute("vistaInvitado", true);
        request.getRequestDispatcher("/registro.jsp").forward(request, response);
    }
}
