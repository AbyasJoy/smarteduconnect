<%@ page import="java.sql.*" %>
<html><body>
<h2>Add Course</h2>

<form method="post">
  Course Code: <input name="code" required><br><br>
  Course Name: <input name="name" required><br><br>
  <button type="submit">Add Course</button>
</form>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&serverTimezone=UTC",
      "root", "Joy@1234"
    );

    PreparedStatement ps = con.prepareStatement(
      "INSERT INTO course (course_code, course_name) VALUES (?,?)"
    );
    ps.setString(1, request.getParameter("code"));
    ps.setString(2, request.getParameter("name"));
    ps.executeUpdate();
    con.close();

    out.println("<p style='color:green'>Course Added ✅</p>");
  } catch(Exception e) {
    out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
  }
}
%>

<br><a href="listCourses.jsp">View Courses</a>
</body></html>