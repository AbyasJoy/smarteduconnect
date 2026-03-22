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
int studentId = 0;

String roll = "";
String name = "";
String studentEmail = "";
String dept = "";
int year = 1;

if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("listStudents.jsp");
    return;
}

try {
    studentId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("listStudents.jsp");
    return;
}

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newRoll = request.getParameter("roll_no");
        String newName = request.getParameter("name");
        String newEmail = request.getParameter("email");
        String newDept = request.getParameter("department");
        int newYear = Integer.parseInt(request.getParameter("year"));

        con.setAutoCommit(false);

        PreparedStatement psOld = con.prepareStatement(
            "SELECT email FROM student WHERE student_id=?"
        );
        psOld.setInt(1, studentId);
        ResultSet rsOld = psOld.executeQuery();

        String oldEmail = "";
        if (rsOld.next()) {
            oldEmail = rsOld.getString("email");
        } else {
            throw new Exception("Student record not found.");
        }
        rsOld.close();
        psOld.close();

        PreparedStatement psStudent = con.prepareStatement(
            "UPDATE student SET roll_no=?, name=?, email=?, department=?, year=? WHERE student_id=?"
        );
        psStudent.setString(1, newRoll);
        psStudent.setString(2, newName);
        psStudent.setString(3, newEmail);
        psStudent.setString(4, newDept);
        psStudent.setInt(5, newYear);
        psStudent.setInt(6, studentId);
        psStudent.executeUpdate();
        psStudent.close();

        PreparedStatement psUsers = con.prepareStatement(
            "UPDATE users SET full_name=?, email=? WHERE email=? AND role='student'"
        );
        psUsers.setString(1, newName);
        psUsers.setString(2, newEmail);
        psUsers.setString(3, oldEmail);
        psUsers.executeUpdate();
        psUsers.close();

        con.commit();
        successMessage = "Student record updated successfully.";
    }

    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM student WHERE student_id=?"
    );
    ps.setInt(1, studentId);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        roll = rs.getString("roll_no");
        name = rs.getString("name");
        studentEmail = rs.getString("email");
        dept = rs.getString("department");
        year = rs.getInt("year");
    } else {
        rs.close();
        ps.close();
        con.close();
        response.sendRedirect("listStudents.jsp");
        return;
    }

    rs.close();
    ps.close();

} catch (NumberFormatException e) {
    try {
        if (con != null) con.rollback();
    } catch (Exception ex) {}
    errorMessage = "Year must be a valid number.";
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
    <title>Update Student - SmartEduConnect</title>
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
            <h2>Update Student</h2>
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
                    <h1>Edit Student Record</h1>
                    <p>Update student information in the SmartEduConnect academic portal.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="listStudents.jsp">Back to Student Records</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Student Details</h3>
                <p class="card-subtitle">Modify the student record below.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Roll Number</label>
                            <input type="text" name="roll_no" value="<%= roll %>" required>
                        </div>

                        <div class="field">
                            <label>Full Name</label>
                            <input type="text" name="name" value="<%= name %>" required>
                        </div>

                        <div class="field">
                            <label>Email Address</label>
                            <input type="email" name="email" value="<%= studentEmail %>" required>
                        </div>

                        <div class="field">
                            <label>Department</label>
                            <input type="text" name="department" value="<%= dept %>" required>
                        </div>

                        <div class="field">
                            <label>Year</label>
                            <input type="number" name="year" min="1" max="4" value="<%= year %>" required>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Update Student</button>
                        <a class="btn btn-secondary" href="listStudents.jsp">Cancel</a>
                    </div>
                </form>
            </div>

        </div>
    </div>

</div>
</body>
</html>