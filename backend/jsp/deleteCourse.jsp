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
    idStr = request.getParameter("course_id");
}

if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("listCourses.jsp");
    return;
}

int courseId = 0;
try {
    courseId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("listCourses.jsp");
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

    PreparedStatement psDeleteFacultyCourse = con.prepareStatement(
        "DELETE FROM faculty_course WHERE course_id=?"
    );
    psDeleteFacultyCourse.setInt(1, courseId);
    psDeleteFacultyCourse.executeUpdate();
    psDeleteFacultyCourse.close();

    PreparedStatement psDeleteAttendance = con.prepareStatement(
        "DELETE FROM attendance WHERE course_id=?"
    );
    psDeleteAttendance.setInt(1, courseId);
    psDeleteAttendance.executeUpdate();
    psDeleteAttendance.close();

    PreparedStatement psDeleteMarks = con.prepareStatement(
        "DELETE FROM marks WHERE course_id=?"
    );
    psDeleteMarks.setInt(1, courseId);
    psDeleteMarks.executeUpdate();
    psDeleteMarks.close();

    PreparedStatement psDeleteAssignment = con.prepareStatement(
        "DELETE FROM assignment WHERE course_id=?"
    );
    psDeleteAssignment.setInt(1, courseId);
    psDeleteAssignment.executeUpdate();
    psDeleteAssignment.close();

    PreparedStatement psDeleteCourse = con.prepareStatement(
        "DELETE FROM course WHERE course_id=?"
    );
    psDeleteCourse.setInt(1, courseId);
    psDeleteCourse.executeUpdate();
    psDeleteCourse.close();

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

response.sendRedirect("listCourses.jsp");
%>