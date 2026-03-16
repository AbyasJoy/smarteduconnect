<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection con = DriverManager.getConnection(
  "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&serverTimezone=UTC",
  "root",
  "Joy@1234"
);

PreparedStatement ps = con.prepareStatement("DELETE FROM student WHERE student_id=?");
ps.setInt(1, Integer.parseInt(id));
ps.executeUpdate();
con.close();

response.sendRedirect("listStudents.jsp");
%>