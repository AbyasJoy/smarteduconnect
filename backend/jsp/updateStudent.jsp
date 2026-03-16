<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");
String roll="", name="", email="", dept="";
int year=1;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&serverTimezone=UTC",
      "root",
      "Joy@1234"
    );

    PreparedStatement ps = con.prepareStatement("SELECT * FROM student WHERE student_id=?");
    ps.setInt(1, Integer.parseInt(id));
    ResultSet rs = ps.executeQuery();
    if(rs.next()){
        roll = rs.getString("roll_no");
        name = rs.getString("name");
        email = rs.getString("email");
        dept = rs.getString("department");
        year = rs.getInt("year");
    }
    con.close();
} catch(Exception e) {}
%>

<html><body>
<h2>Update Student</h2>

<form method="post">
  Roll No: <input name="roll_no" value="<%= roll %>" required><br><br>
  Name: <input name="name" value="<%= name %>" required><br><br>
  Email: <input name="email" value="<%= email %>" required><br><br>
  Department: <input name="department" value="<%= dept %>" required><br><br>
  Year: <input name="year" type="number" min="1" max="4" value="<%= year %>" required><br><br>
  <button type="submit">Update</button>
</form>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
          "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&serverTimezone=UTC",
          "root",
          "Joy@1234"
        );

        PreparedStatement ps = con.prepareStatement(
          "UPDATE student SET roll_no=?, name=?, email=?, department=?, year=? WHERE student_id=?"
        );

        ps.setString(1, request.getParameter("roll_no"));
        ps.setString(2, request.getParameter("name"));
        ps.setString(3, request.getParameter("email"));
        ps.setString(4, request.getParameter("department"));
        ps.setInt(5, Integer.parseInt(request.getParameter("year")));
        ps.setInt(6, Integer.parseInt(id));

        ps.executeUpdate();
        con.close();

        out.println("<p style='color:green'>Updated ✅</p>");
    } catch(Exception e) {
        out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
    }
}
%>

<br><a href="listStudents.jsp">Back</a>
</body></html>