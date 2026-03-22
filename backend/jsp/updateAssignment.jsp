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

if (!"faculty".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

String successMessage = "";
String errorMessage = "";

String idStr = request.getParameter("id");
if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("assignments.jsp");
    return;
}

int assignmentId = 0;
try {
    assignmentId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("assignments.jsp");
    return;
}

String title = "";
String description = "";
String dueDate = "";
String status = "";
String courseCode = "";
String courseName = "";

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newTitle = request.getParameter("title");
        String newDescription = request.getParameter("description");
        String newDueDate = request.getParameter("due_date");
        String newStatus = request.getParameter("status");

        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) " +
            "FROM assignment a " +
            "JOIN faculty_course fc ON a.course_id = fc.course_id " +
            "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
            "WHERE a.assignment_id=? AND f.email=?"
        );
        psCheck.setInt(1, assignmentId);
        psCheck.setString(2, email);
        ResultSet rsCheck = psCheck.executeQuery();

        int allowed = 0;
        if (rsCheck.next()) {
            allowed = rsCheck.getInt(1);
        }
        rsCheck.close();
        psCheck.close();

        if (allowed == 0) {
            throw new Exception("You can update only your assigned course assignments.");
        }

        PreparedStatement psUpdate = con.prepareStatement(
            "UPDATE assignment SET title=?, description=?, due_date=?, status=? WHERE assignment_id=?"
        );
        psUpdate.setString(1, newTitle);
        psUpdate.setString(2, newDescription);
        psUpdate.setDate(3, java.sql.Date.valueOf(newDueDate));
        psUpdate.setString(4, newStatus);
        psUpdate.setInt(5, assignmentId);
        psUpdate.executeUpdate();
        psUpdate.close();

        successMessage = "Assignment updated successfully.";
    }

    PreparedStatement psLoad = con.prepareStatement(
        "SELECT a.title, a.description, a.due_date, a.status, c.course_code, c.course_name " +
        "FROM assignment a " +
        "JOIN faculty_course fc ON a.course_id = fc.course_id " +
        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
        "JOIN course c ON a.course_id = c.course_id " +
        "WHERE a.assignment_id=? AND f.email=?"
    );
    psLoad.setInt(1, assignmentId);
    psLoad.setString(2, email);
    ResultSet rsLoad = psLoad.executeQuery();

    if (rsLoad.next()) {
        title = rsLoad.getString("title");
        description = rsLoad.getString("description");
        dueDate = String.valueOf(rsLoad.getDate("due_date"));
        status = rsLoad.getString("status");
        courseCode = rsLoad.getString("course_code");
        courseName = rsLoad.getString("course_name");
    } else {
        rsLoad.close();
        psLoad.close();
        con.close();
        response.sendRedirect("assignments.jsp");
        return;
    }

    rsLoad.close();
    psLoad.close();

} catch (Exception e) {
    errorMessage = "Error: " + e.getMessage();
} finally {
    try {
        if (con != null) con.close();
    } catch (Exception ex) {}
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Assignment - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="app">

    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge">Faculty Panel</div>

        <div class="nav-section">Overview</div>
        <a href="facultyDashboard.jsp">Dashboard</a>

        <div class="nav-section">Academic</div>
        <a href="listCourses.jsp">Assigned Courses</a>
        <a href="attendance.jsp">Manage Attendance</a>
        <a href="marks.jsp">Upload Marks</a>
        <a class="active" href="assignments.jsp">Assignments</a>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Update Assignment</h2>
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
                    <h1>Edit Assignment</h1>
                    <p>Course: <b><%= courseCode %></b> - <%= courseName %></p>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Assignment Details</h3>
                <p class="card-subtitle">Modify assignment information and status.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Title</label>
                            <input type="text" name="title" value="<%= title %>" required>
                        </div>

                        <div class="field">
                            <label>Due Date</label>
                            <input type="date" name="due_date" value="<%= dueDate %>" required>
                        </div>

                        <div class="field">
                            <label>Status</label>
                            <select name="status" required>
                                <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                                <option value="Submitted" <%= "Submitted".equals(status) ? "selected" : "" %>>Submitted</option>
                                <option value="Upcoming" <%= "Upcoming".equals(status) ? "selected" : "" %>>Upcoming</option>
                            </select>
                        </div>

                        <div class="field" style="grid-column: 1 / -1;">
                            <label>Description</label>
                            <textarea name="description" required><%= description %></textarea>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Update Assignment</button>
                        <a class="btn btn-secondary" href="assignments.jsp">Back</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>
</body>
</html>