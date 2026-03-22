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

if (!"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

int totalStudents = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    Statement stCount = con.createStatement();
    ResultSet rsCount = stCount.executeQuery("SELECT COUNT(*) FROM student");
    if (rsCount.next()) {
        totalStudents = rsCount.getInt(1);
    }

    rsCount.close();
    stCount.close();
    con.close();

} catch (Exception e) {
    out.println("<p style='color:red; padding:10px;'>Error: " + e.getMessage() + "</p>");
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Management - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="app">

    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge">Admin Panel</div>

        <div class="nav-section">Overview</div>
        <a href="adminDashboard.jsp">Dashboard</a>

        <div class="nav-section">Management</div>
        <a href="addStudent.jsp">Add Student</a>
        <a class="active" href="listStudents.jsp">Manage Students</a>
        <a href="addFaculty.jsp">Add Faculty</a>
        <a href="listFaculty.jsp">Manage Faculty</a>
        <a href="addCourse.jsp">Add Course</a>
        <a href="listCourses.jsp">Manage Courses</a>
        <a href="assignCourseFaculty.jsp">Assign Courses</a>

        <div class="nav-section">Monitoring</div>
        <a href="assignments.jsp">Assignments Overview</a>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Student Management</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div class="page-title">
                    <h1>Manage Students</h1>
                    <p>View, update, and maintain student records in the SmartEduConnect academic portal.</p>
                </div>

                <div class="page-actions">
                    <a class="btn" href="addStudent.jsp">Add Student</a>
                    <a class="btn btn-secondary" href="adminDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Total Students</div>
                    <div class="kpi-value"><%= totalStudents %></div>
                    <div class="kpi-subtext">Registered student records</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Role</div>
                    <div class="kpi-value">Admin</div>
                    <div class="kpi-subtext">Institution-level access</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Module</div>
                    <div class="kpi-value">Live</div>
                    <div class="kpi-subtext">Student management enabled</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Permissions</div>
                    <div class="kpi-value">Full</div>
                    <div class="kpi-subtext">Create, update, delete</div>
                </div>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Student Records</h3>
                    <p>All registered student profiles available in the system.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Roll No</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Year</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>

<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("SELECT * FROM student ORDER BY student_id DESC");

    while (rs.next()) {
%>
                        <tr>
                            <td><%= rs.getInt("student_id") %></td>
                            <td><%= rs.getString("roll_no") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getString("department") %></td>
                            <td><%= rs.getInt("year") %></td>
                            <td>
                                <a class="btn btn-secondary" href="updateStudent.jsp?id=<%= rs.getInt("student_id") %>">Edit</a>
                            </td>
                            <td>
                                <a class="btn btn-danger" href="deleteStudent.jsp?id=<%= rs.getInt("student_id") %>"
                                   onclick="return confirm('Delete this student?')">Delete</a>
                            </td>
                        </tr>
<%
    }

    rs.close();
    st.close();
    con.close();

} catch (Exception e) {
%>
                        <tr>
                            <td colspan="8" style="color:red;">Error: <%= e.getMessage() %></td>
                        </tr>
<%
}
%>
                    </table>
                </div>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Admin Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Admins can create, update, view, and delete student records. This module provides institution-level student data management.</p>
            </div>
        </div>
    </div>

</div>
</body>
</html>