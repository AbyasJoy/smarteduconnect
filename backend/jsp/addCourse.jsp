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
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        String code = request.getParameter("code");
        String name = request.getParameter("name");

        // Prevent duplicate course codes
        PreparedStatement check = con.prepareStatement(
            "SELECT COUNT(*) FROM course WHERE course_code=?"
        );
        check.setString(1, code);
        ResultSet rsCheck = check.executeQuery();

        int exists = 0;
        if (rsCheck.next()) {
            exists = rsCheck.getInt(1);
        }

        if (exists > 0) {
            errorMessage = "Course code already exists.";
        } else {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO course (course_code, course_name) VALUES (?,?)"
            );
            ps.setString(1, code);
            ps.setString(2, name);

            ps.executeUpdate();
            successMessage = "Course added successfully.";

            ps.close();
        }

        rsCheck.close();
        check.close();
        con.close();

    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Course - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
<div class="app">

    <!-- Sidebar -->
    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge">Admin Panel</div>

        <div class="nav-section">Overview</div>
        <a href="adminDashboard.jsp">Dashboard</a>

        <div class="nav-section">Management</div>
        <a href="addStudent.jsp">Add Student</a>
        <a href="listStudents.jsp">Manage Students</a>
        <a href="addFaculty.jsp">Add Faculty</a>
        <a href="listFaculty.jsp">Manage Faculty</a>
        <a class="active" href="addCourse.jsp">Add Course</a>
        <a href="listCourses.jsp">Manage Courses</a>
        <a href="assignCourseFaculty.jsp">Assign Courses</a>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <!-- Main -->
    <div class="main">
        <div class="topbar">
            <h2>Add Course</h2>
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
                    <h1>Create New Course</h1>
                    <p>Add new academic courses into the SmartEduConnect system.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="listCourses.jsp">View Courses</a>
                    <a class="btn btn-secondary" href="adminDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <!-- Form -->
            <div class="card form-shell">
                <h3 class="card-title">Course Details</h3>
                <p class="card-subtitle">Enter valid course information.</p>

                <form method="post">

                    <div class="form-grid">

                        <div class="field">
                            <label>Course Code</label>
                            <input type="text" name="code" placeholder="e.g. CS101" required>
                        </div>

                        <div class="field">
                            <label>Course Name</label>
                            <input type="text" name="name" placeholder="e.g. Data Structures" required>
                        </div>

                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Add Course</button>
                    </div>

                </form>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Admin Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Admins can create and manage courses. Course assignment to faculty is handled in the course allocation module.</p>
            </div>

        </div>
    </div>

</div>
</body>
</html>