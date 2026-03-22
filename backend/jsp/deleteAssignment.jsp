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

if (!"faculty".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String idStr = request.getParameter("id");
if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("assignments.jsp");
    return;
}

int assignmentId = 0;
try {
    assignmentId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("assignments.jsp");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement psCheck = con.prepareStatement(
        "SELECT COUNT(*) " +
        "FROM assignment a " +
        "JOIN faculty_course fc ON a.course_id = fc.course_id " +
        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
        "WHERE a.assignment_id=? AND f.email=?"
    );
    psCheck.setInt(1, assignmentId);
    psCheck.setString(2, email);
    ResultSet rsCheck = psCheck.executeQuery();

    int allowed = 0;
    if (rsCheck.next()) {
        allowed = rsCheck.getInt(1);
    }
    rsCheck.close();
    psCheck.close();

    if (allowed > 0) {
        PreparedStatement psDelete = con.prepareStatement(
            "DELETE FROM assignment WHERE assignment_id=?"
        );
        psDelete.setInt(1, assignmentId);
        psDelete.executeUpdate();
        psDelete.close();
    }

    con.close();

} catch (Exception e) {
} finally {
    try {
        if (con != null) con.close();
    } catch (Exception ex) {}
}

response.sendRedirect("assignments.jsp");
%>