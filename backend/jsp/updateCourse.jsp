<%@ page import="java.sql.*" %>
<%
String URL="jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER="root";
String PASS="YOUR_PASSWORD";

String idStr = request.getParameter("course_id");
if(idStr==null){ out.println("course_id missing"); return; }

int courseId = Integer.parseInt(idStr);
String code="", name="";

if("POST".equalsIgnoreCase(request.getMethod())){
    code = request.getParameter("course_code");
    name = request.getParameter("course_name");

    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL,USER,PASS);

        PreparedStatement ps = con.prepareStatement(
            "UPDATE course SET course_code=?, course_name=? WHERE course_id=?"
        );
        ps.setString(1, code);
        ps.setString(2, name);
        ps.setInt(3, courseId);

        ps.executeUpdate();
        con.close();

        response.sendRedirect("listCourses.jsp");
        return;
    }catch(Exception e){
        out.println("<p style='color:red'>Error: "+e.getMessage()+"</p>");
    }
} else {
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL,USER,PASS);

        PreparedStatement ps = con.prepareStatement(
            "SELECT course_code, course_name FROM course WHERE course_id=?"
        );
        ps.setInt(1, courseId);
        ResultSet rs = ps.executeQuery();

        if(rs.next()){
            code = rs.getString("course_code");
            name = rs.getString("course_name");
        }
        con.close();
    }catch(Exception e){
        out.println("<p style='color:red'>Error: "+e.getMessage()+"</p>");
    }
}
%>

<html><body>
<h2>Edit Course</h2>

<form method="post">
  Course Code: <input name="course_code" value="<%=code%>" required><br><br>
  Course Name: <input name="course_name" value="<%=name%>" required><br><br>
  <button type="submit">Update</button>
</form>

<br><a href="listCourses.jsp">Back</a>
</body></html>