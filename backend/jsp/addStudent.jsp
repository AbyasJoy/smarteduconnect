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

String successMessage = "";
String errorMessage = "";

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String roll = request.getParameter("roll_no");
    String name = request.getParameter("name");
    String studentEmail = request.getParameter("email");
    String dept = request.getParameter("department");
    String yearStr = request.getParameter("year");

    String defaultPassword = "Student@1234";
    String studentRole = "student";

    Connection con = null;

    try {
        int year = Integer.parseInt(yearStr);

        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(URL, USER, PASS);
        con.setAutoCommit(false);

        PreparedStatement psCheckUser = con.prepareStatement(
            "SELECT COUNT(*) FROM users WHERE email=?"
        );
        psCheckUser.setString(1, studentEmail);
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

        PreparedStatement psCheckStudent = con.prepareStatement(
            "SELECT COUNT(*) FROM student WHERE email=? OR roll_no=?"
        );
        psCheckStudent.setString(1, studentEmail);
        psCheckStudent.setString(2, roll);
        ResultSet rsCheckStudent = psCheckStudent.executeQuery();

        int studentExists = 0;
        if (rsCheckStudent.next()) {
            studentExists = rsCheckStudent.getInt(1);
        }
        rsCheckStudent.close();
        psCheckStudent.close();

        if (studentExists > 0) {
            throw new Exception("Student record with same email or roll number already exists.");
        }

        PreparedStatement psUser = con.prepareStatement(
            "INSERT INTO users (full_name, email, password, role, is_active) VALUES (?, ?, ?, ?, 1)"
        );
        psUser.setString(1, name);
        psUser.setString(2, studentEmail);
        psUser.setString(3, defaultPassword);
        psUser.setString(4, studentRole);
        psUser.executeUpdate();
        psUser.close();

        PreparedStatement psStudent = con.prepareStatement(
            "INSERT INTO student (roll_no, name, email, department, year) VALUES (?, ?, ?, ?, ?)"
        );
        psStudent.setString(1, roll);
        psStudent.setString(2, name);
        psStudent.setString(3, studentEmail);
        psStudent.setString(4, dept);
        psStudent.setInt(5, year);
        psStudent.executeUpdate();
        psStudent.close();

        con.commit();

        successMessage = "Student added successfully. Default login password: " + defaultPassword;

    } catch (NumberFormatException e) {
        if (con != null) {
            try { con.rollback(); } catch (Exception ex) {}
        }
        errorMessage = "Year must be a valid number.";
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
    <title>Add Student - SmartEduConnect</title>
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
        <a class="active" href="addStudent.jsp">Add Student</a>
        <a href="listStudents.jsp">Manage Students</a>
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
            <h2>Add Student</h2>
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
                    <h1>Create Student Record</h1>
                    <p>Create a new student record in the SmartEduConnect academic portal.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="listStudents.jsp">View Students</a>
                    <a class="btn btn-secondary" href="adminDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Student Details</h3>
                <p class="card-subtitle">Enter the required student information below.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label for="roll_no">Roll Number</label>
                            <input type="text" id="roll_no" name="roll_no" placeholder="Ex: CSE202401" required>
                        </div>

                        <div class="field">
                            <label for="name">Full Name</label>
                            <input type="text" id="name" name="name" placeholder="Ex: Abyas Joy Ganta" required>
                        </div>

                        <div class="field">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" placeholder="Ex: joy.student@smartedu.com" required>
                        </div>

                        <div class="field">
                            <label for="department">Department</label>
                            <input type="text" id="department" name="department" placeholder="Ex: CSE" required>
                        </div>

                        <div class="field">
                            <label for="year">Year</label>
                            <input type="number" id="year" name="year" min="1" max="4" placeholder="1 to 4" required>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Add Student</button>
                        <a class="btn btn-secondary" href="listStudents.jsp">Cancel</a>
                    </div>
                </form>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Admin Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Admins can create student login accounts in the users table and maintain academic profile records in the student table for attendance, marks, assignments, and academic tracking workflows.</p>
            </div>

        </div>
    </div>

</div>
</body>
</html>