<%@ page import="java.sql.*" %>
<html><body>
<h2>Assign Course to Faculty</h2>

<form method="post">
  Faculty ID: <input name="faculty_id" required><br><br>
  Course ID: <input name="course_id" required><br><br>
  <button type="submit">Assign</button>
</form>

<%
String URL="jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER="root";
String PASS="Joy@1234";

if("POST".equalsIgnoreCase(request.getMethod())){
  try{
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con=DriverManager.getConnection(URL,USER,PASS);

    PreparedStatement ps=con.prepareStatement(
      "INSERT INTO faculty_course(faculty_id,course_id) VALUES(?,?)"
    );
    ps.setInt(1,Integer.parseInt(request.getParameter("faculty_id")));
    ps.setInt(2,Integer.parseInt(request.getParameter("course_id")));
    ps.executeUpdate();

    con.close();
    out.println("<p style='color:green'>Assigned ✅</p>");
  }catch(Exception e){
    out.println("<p style='color:red'>Error: "+e.getMessage()+"</p>");
  }
}
%>

<hr>
<h3>Assigned Courses</h3>
<table border="1" cellpadding="8">
<tr><th>Faculty</th><th>Course</th></tr>

<%
try{
  Class.forName("com.mysql.cj.jdbc.Driver");
  Connection con=DriverManager.getConnection(URL,USER,PASS);

  Statement st=con.createStatement();
  ResultSet rs=st.executeQuery(
    "SELECT f.faculty_name, c.course_code " +
    "FROM faculty_course fc " +
    "JOIN faculty f ON fc.faculty_id=f.faculty_id " +
    "JOIN course c ON fc.course_id=c.course_id " +
    "ORDER BY fc.fc_id DESC"
  );

  while(rs.next()){
%>
<tr>
  <td><%=rs.getString(1)%></td>
  <td><%=rs.getString(2)%></td>
</tr>
<%
  }
  con.close();
}catch(Exception e){
  out.println("<tr><td colspan='2' style='color:red'>Error: "+e.getMessage()+"</td></tr>");
}
%>
</table>

<br><a href="listFaculty.jsp">Back to Faculty List</a>
</body></html>