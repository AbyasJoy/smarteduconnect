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

String successMessage = "";
String errorMessage = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String facultyName = request.getParameter("name");
    String facultyEmail = request.getParameter("email");
    String department = request.getParameter("dept");

    String defaultPassword = "Faculty@1234";
    String facultyRole = "faculty";

    Connection con = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(URL, USER, PASS);
        con.setAutoCommit(false);

        PreparedStatement psCheckUser = con.prepareStatement(
            "SELECT COUNT(*) FROM users WHERE email=?"
        );
        psCheckUser.setString(1, facultyEmail);
        ResultSet rsCheckUser = psCheckUser.executeQuery();

        int userExists = 0;
        if (rsCheckUser.next()) {
            userExists = rsCheckUser.getInt(1);
        }
        rsCheckUser.close();
        psCheckUser.close();

        if (userExists > 0) {
            throw new Exception("A user account with this email already exists.");
        }

        PreparedStatement psCheckFaculty = con.prepareStatement(
            "SELECT COUNT(*) FROM faculty WHERE email=?"
        );
        psCheckFaculty.setString(1, facultyEmail);
        ResultSet rsCheckFaculty = psCheckFaculty.executeQuery();

        int facultyExists = 0;
        if (rsCheckFaculty.next()) {
            facultyExists = rsCheckFaculty.getInt(1);
        }
        rsCheckFaculty.close();
        psCheckFaculty.close();

        if (facultyExists > 0) {
            throw new Exception("Faculty record with this email already exists.");
        }

        PreparedStatement psUser = con.prepareStatement(
            "INSERT INTO users (full_name, email, password, role, is_active) VALUES (?, ?, ?, ?, 1)"
        );
        psUser.setString(1, facultyName);
        psUser.setString(2, facultyEmail);
        psUser.setString(3, defaultPassword);
        psUser.setString(4, facultyRole);
        psUser.executeUpdate();
        psUser.close();

        PreparedStatement psFaculty = con.prepareStatement(
            "INSERT INTO faculty (faculty_name, email, department) VALUES (?, ?, ?)"
        );
        psFaculty.setString(1, facultyName);
        psFaculty.setString(2, facultyEmail);
        psFaculty.setString(3, department);
        psFaculty.executeUpdate();
        psFaculty.close();

        con.commit();

        successMessage = "Faculty added successfully. Default login password: " + defaultPassword;

    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (Exception ex) {}
        }
        errorMessage = "Error: " + e.getMessage();
    } finally {
        if (con != null) {
            try {
                con.setAutoCommit(true);
                con.close();
            } catch (Exception ex) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Faculty - SmartEduConnect</title>
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
        <a class="active" href="addFaculty.jsp">Add Faculty</a>
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
            <h2>Add Faculty</h2>
            <div class="user-meta"><%= email %></div>
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
                    <h1>Create Faculty Record</h1>
                    <p>Add a new faculty member into the SmartEduConnect academic system.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="listFaculty.jsp">View Faculty</a>
                    <a class="btn btn-secondary" href="adminDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Faculty Details</h3>
                <p class="card-subtitle">Enter valid faculty information below.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Faculty Name</label>
                            <input type="text" name="name" placeholder="Ex: Dr. Meera Sharma" required>
                        </div>

                        <div class="field">
                            <label>Faculty Email</label>
                            <input type="email" name="email" placeholder="Ex: meera.faculty@smartedu.com" required>
                        </div>

                        <div class="field">
                            <label>Department</label>
                            <input type="text" name="dept" placeholder="Ex: CSE" required>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Add Faculty</button>
                        <a class="btn btn-secondary" href="listFaculty.jsp">Cancel</a>
                    </div>
                </form>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Admin Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Admins can create faculty login accounts in the users table and maintain academic profile records in the faculty table for system-wide access control.</p>
            </div>

        </div>
    </div>

</div>
</body>
</html>