import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        response.setContentType("text/xml");
        PrintWriter out = response.getWriter();

        out.println("<response>");
        out.println("<email>" + email + "</email>");
        out.println("<status>Login Successful</status>");
        out.println("</response>");
    }
}
