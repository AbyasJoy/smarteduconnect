import java.io.PrintWriter;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class StudentProfileServlet extends HttpServlet {

    private String xmlEscape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/xml; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<profileResponse>");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("email") == null) {
            out.println("<status>FAIL</status>");
            out.println("<message>Not logged in</message>");
            out.println("</profileResponse>");
            return;
        }

        String email = (String) session.getAttribute("email");

        String id = "";
        String name = "";
        String department = "";
        String year = "";

        // Dynamic demo logic (replace with DB later)
        if (email.equalsIgnoreCase("alice@gmail.com")) {
            id = "AU24CSE101";
            name = "Alice Johnson";
            department = "CSE";
            year = "2";
        } 
        else if (email.equalsIgnoreCase("bob@gmail.com")) {
            id = "AU24ECE202";
            name = "Bob Smith";
            department = "ECE";
            year = "3";
        } 
        else {
            id = "AU24GEN999";
            name = "Guest Student";
            department = "General";
            year = "1";
        }

        out.println("<status>SUCCESS</status>");
        out.println("<student>");
        out.println("<id>" + xmlEscape(id) + "</id>");
        out.println("<name>" + xmlEscape(name) + "</name>");
        out.println("<email>" + xmlEscape(email) + "</email>");
        out.println("<department>" + xmlEscape(department) + "</department>");
        out.println("<year>" + xmlEscape(year) + "</year>");
        out.println("</student>");

        out.println("</profileResponse>");
    }
}