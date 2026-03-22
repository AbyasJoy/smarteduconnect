<%@ page import="java.sql.*" %>
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

String role = (String) session.getAttribute("role");
String email = (String) session.getAttribute("email");

if (role == null || email == null) {
    response.sendRedirect("login.html");
    return;
}

if (!"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String idStr = request.getParameter("id");
if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("assignCourseFaculty.jsp");
    return;
}

int fcId = 0;
try {
    fcId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("assignCourseFaculty.jsp");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement ps = con.prepareStatement(
        "DELETE FROM faculty_course WHERE fc_id=?"
    );
    ps.setInt(1, fcId);
    ps.executeUpdate();
    ps.close();

    con.close();

} catch (Exception e) {
} finally {
    try {
        if (con != null) con.close();
    } catch (Exception ex) {}
}

response.sendRedirect("assignCourseFaculty.jsp");
%>