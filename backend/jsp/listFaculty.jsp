<%@ page import="java.sql.*" %>
<html><body>
<h2>Faculty List</h2>

<table border="1" cellpadding="8">
<tr><th>ID</th><th>Name</th><th>Email</th><th>Dept</th></tr>

<%
String URL="jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER="root";
String PASS="Joy@1234";

try{
  Class.forName("com.mysql.cj.jdbc.Driver");
  Connection con=DriverManager.getConnection(URL,USER,PASS);

  Statement st=con.createStatement();
  ResultSet rs=st.executeQuery("SELECT * FROM faculty ORDER BY faculty_id DESC");

  while(rs.next()){
%>
<tr>
  <td><%=rs.getInt("faculty_id")%></td>
  <td><%=rs.getString("faculty_name")%></td>
  <td><%=rs.getString("email")%></td>
  <td><%=rs.getString("department")%></td>
</tr>
<%
  }
  con.close();
}catch(Exception e){
  out.println("<tr><td colspan='4' style='color:red'>Error: "+e.getMessage()+"</td></tr>");
}
%>
</table>

<br>
<a href="addFaculty.jsp">Add Faculty</a> |
<a href="assignCourseFaculty.jsp">Assign Courses</a>
</body></html>