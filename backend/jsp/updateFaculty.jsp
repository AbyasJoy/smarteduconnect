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

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

String successMessage = "";
String errorMessage = "";

String idStr = request.getParameter("id");
int facultyId = 0;

String facultyName = "";
String facultyEmail = "";
String department = "";

if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("listFaculty.jsp");
    return;
}

try {
    facultyId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("listFaculty.jsp");
    return;
}

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newName = request.getParameter("name");
        String newEmail = request.getParameter("email");
        String newDept = request.getParameter("department");

        con.setAutoCommit(false);

        PreparedStatement psOld = con.prepareStatement(
            "SELECT email FROM faculty WHERE faculty_id=?"
        );
        psOld.setInt(1, facultyId);
        ResultSet rsOld = psOld.executeQuery();

        String oldEmail = "";
        if (rsOld.next()) {
            oldEmail = rsOld.getString("email");
        } else {
            throw new Exception("Faculty record not found.");
        }
        rsOld.close();
        psOld.close();

        PreparedStatement psFaculty = con.prepareStatement(
            "UPDATE faculty SET faculty_name=?, email=?, department=? WHERE faculty_id=?"
        );
        psFaculty.setString(1, newName);
        psFaculty.setString(2, newEmail);
        psFaculty.setString(3, newDept);
        psFaculty.setInt(4, facultyId);
        psFaculty.executeUpdate();
        psFaculty.close();

        PreparedStatement psUsers = con.prepareStatement(
            "UPDATE users SET full_name=?, email=? WHERE email=? AND role='faculty'"
        );
        psUsers.setString(1, newName);
        psUsers.setString(2, newEmail);
        psUsers.setString(3, oldEmail);
        psUsers.executeUpdate();
        psUsers.close();

        con.commit();
        successMessage = "Faculty record updated successfully.";
    }

    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM faculty WHERE faculty_id=?"
    );
    ps.setInt(1, facultyId);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        facultyName = rs.getString("faculty_name");
        facultyEmail = rs.getString("email");
        department = rs.getString("department");
    } else {
        rs.close();
        ps.close();
        con.close();
        response.sendRedirect("listFaculty.jsp");
        return;
    }

    rs.close();
    ps.close();

} catch (Exception e) {
    try {
        if (con != null) con.rollback();
    } catch (Exception ex) {}
    errorMessage = "Error: " + e.getMessage();
} finally {
    try {
        if (con != null) {
            con.setAutoCommit(true);
            con.close();
        }
    } catch (Exception ex) {}
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Faculty - SmartEduConnect</title>
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
        <a href="listStudents.jsp">Manage Students</a>
        <a href="addFaculty.jsp">Add Faculty</a>
        <a class="active" href="listFaculty.jsp">Manage Faculty</a>
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
            <h2>Update Faculty</h2>
            <div class="user-meta"><%= emailSession %></div>
        </div>

        <div class="page-content">

            <% if (!successMessage.isEmpty()) { %>
                <div class="alert-success"><%= successMessage %></div>
            <% } %>

            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert-error"><%= errorMessage %></div>
            <% } %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Edit Faculty Record</h1>
                    <p>Update faculty information in the SmartEduConnect academic portal.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="listFaculty.jsp">Back to Faculty Records</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Faculty Details</h3>
                <p class="card-subtitle">Modify the faculty record below.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Faculty Name</label>
                            <input type="text" name="name" value="<%= facultyName %>" required>
                        </div>

                        <div class="field">
                            <label>Faculty Email</label>
                            <input type="email" name="email" value="<%= facultyEmail %>" required>
                        </div>

                        <div class="field">
                            <label>Department</label>
                            <input type="text" name="department" value="<%= department %>" required>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Update Faculty</button>
                        <a class="btn btn-secondary" href="listFaculty.jsp">Cancel</a>
                    </div>
                </form>
            </div>

        </div>
    </div>

</div>
</body>
</html>