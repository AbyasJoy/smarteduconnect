import java.io.PrintWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LoginServlet extends HttpServlet {

    String DB_URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "Joy@1234";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        response.setContentType("text/xml; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<response>");

        if (email == null || password == null || role == null ||
            email.trim().isEmpty() || password.trim().isEmpty() || role.trim().isEmpty()) {

            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            out.println("<status>FAIL</status>");
            out.println("<message>All fields are required.</message>");
            out.println("</response>");
            return;
        }

        email = email.trim();
        password = password.trim();
        role = role.trim().toLowerCase();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "SELECT user_id, full_name, email, role FROM users WHERE email=? AND password=? AND role=? AND is_active=1";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            ps.setString(3, role);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) oldSession.invalidate();

                HttpSession session = request.getSession(true);
                session.setAttribute("user_id", rs.getInt("user_id"));
                session.setAttribute("name", rs.getString("full_name"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("role", rs.getString("role"));

                out.println("<status>SUCCESS</status>");
                out.println("<message>Login Successful</message>");
                out.println("<role>" + rs.getString("role") + "</role>");
            } else {
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) oldSession.invalidate();

                out.println("<status>FAIL</status>");
                out.println("<message>Invalid email, password or role</message>");
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            out.println("<status>FAIL</status>");
            out.println("<message>Server error: " + e.getMessage() + "</message>");
        }

        out.println("</response>");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/xml; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<response>");
        out.println("<status>INFO</status>");
        out.println("<message>Use POST method for login</message>");
        out.println("</response>");
    }
}