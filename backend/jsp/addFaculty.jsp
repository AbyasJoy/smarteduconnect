<%@ page import="java.sql.*" %>
<html><body>
<h2>Add Faculty</h2>

<form method="post">
  Name: <input name="name" required><br><br>
  Email: <input name="email" required><br><br>
  Department: <input name="dept" required><br><br>
  <button type="submit">Add Faculty</button>
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
      "INSERT INTO faculty(faculty_name,email,department) VALUES(?,?,?)"
    );
    ps.setString(1, request.getParameter("name"));
    ps.setString(2, request.getParameter("email"));
    ps.setString(3, request.getParameter("dept"));
    ps.executeUpdate();

    con.close();
    out.println("<p style='color:green'>Faculty Added ✅</p>");
  }catch(Exception e){
    out.println("<p style='color:red'>Error: "+e.getMessage()+"</p>");
  }
}
%>

<br><a href="listFaculty.jsp">View Faculty</a>
</body></html>