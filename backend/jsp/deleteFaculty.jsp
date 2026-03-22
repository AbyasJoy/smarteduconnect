<%@ page import="java.sql.*" %>
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

String role = (String) session.getAttribute("role");
String emailSession = (String) session.getAttribute("email");

if (role == null || emailSession == null) {
    response.sendRedirect("login.html");
    return;
}

if (!"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String idStr = request.getParameter("id");
if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("listFaculty.jsp");
    return;
}

int facultyId = 0;
try {
    facultyId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("listFaculty.jsp");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);
    con.setAutoCommit(false);

    PreparedStatement psFind = con.prepareStatement(
        "SELECT email FROM faculty WHERE faculty_id=?"
    );
    psFind.setInt(1, facultyId);
    ResultSet rsFind = psFind.executeQuery();

    String facultyEmail = "";
    if (rsFind.next()) {
        facultyEmail = rsFind.getString("email");
    } else {
        rsFind.close();
        psFind.close();
        con.close();
        response.sendRedirect("listFaculty.jsp");
        return;
    }
    rsFind.close();
    psFind.close();

    PreparedStatement psDeleteFacultyCourse = con.prepareStatement(
        "DELETE FROM faculty_course WHERE faculty_id=?"
    );
    psDeleteFacultyCourse.setInt(1, facultyId);
    psDeleteFacultyCourse.executeUpdate();
    psDeleteFacultyCourse.close();

    PreparedStatement psDeleteFaculty = con.prepareStatement(
        "DELETE FROM faculty WHERE faculty_id=?"
    );
    psDeleteFaculty.setInt(1, facultyId);
    psDeleteFaculty.executeUpdate();
    psDeleteFaculty.close();

    PreparedStatement psDeleteUser = con.prepareStatement(
        "DELETE FROM users WHERE email=? AND role='faculty'"
    );
    psDeleteUser.setString(1, facultyEmail);
    psDeleteUser.executeUpdate();
    psDeleteUser.close();

    con.commit();

} catch (Exception e) {
    try {
        if (con != null) con.rollback();
    } catch (Exception ex) {}
} finally {
    try {
        if (con != null) {
            con.setAutoCommit(true);
            con.close();
        }
    } catch (Exception ex) {}
}

response.sendRedirect("listFaculty.jsp");
%>