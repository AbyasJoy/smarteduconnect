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
String facultyName = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement psFaculty = con.prepareStatement(
        "SELECT faculty_name FROM faculty WHERE email=?"
    );
    psFaculty.setString(1, email);
    ResultSet rsFaculty = psFaculty.executeQuery();

    if (rsFaculty.next()) {
        facultyName = rsFaculty.getString("faculty_name");
    }

    rsFaculty.close();
    psFaculty.close();
    con.close();
} catch (Exception e) {
    errorMessage = "Error: " + e.getMessage();
}

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String courseIdStr = request.getParameter("course_id");
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String dueDateStr = request.getParameter("due_date");
    String status = request.getParameter("status");

    try {
        int courseId = Integer.parseInt(courseIdStr);

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement psFaculty = con.prepareStatement(
            "SELECT faculty_id FROM faculty WHERE email=?"
        );
        psFaculty.setString(1, email);
        ResultSet rsFaculty = psFaculty.executeQuery();

        int facultyId = 0;
        if (rsFaculty.next()) {
            facultyId = rsFaculty.getInt("faculty_id");
        }
        rsFaculty.close();
        psFaculty.close();

        if (facultyId == 0) {
            throw new Exception("Faculty account not found.");
        }

        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) FROM faculty_course WHERE faculty_id=? AND course_id=?"
        );
        psCheck.setInt(1, facultyId);
        psCheck.setInt(2, courseId);
        ResultSet rsCheck = psCheck.executeQuery();

        int allowed = 0;
        if (rsCheck.next()) {
            allowed = rsCheck.getInt(1);
        }
        rsCheck.close();
        psCheck.close();

        if (allowed == 0) {
            throw new Exception("You can upload assignments only for your assigned courses.");
        }

        PreparedStatement psInsert = con.prepareStatement(
            "INSERT INTO assignment (course_id, title, description, due_date, status) VALUES (?, ?, ?, ?, ?)"
        );
        psInsert.setInt(1, courseId);
        psInsert.setString(2, title);
        psInsert.setString(3, description);
        psInsert.setDate(4, java.sql.Date.valueOf(dueDateStr));
        psInsert.setString(5, status);
        psInsert.executeUpdate();

        psInsert.close();
        con.close();

        successMessage = "Assignment uploaded successfully.";

    } catch (NumberFormatException e) {
        errorMessage = "Invalid course selected.";
    } catch (IllegalArgumentException e) {
        errorMessage = "Invalid due date.";
    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Upload Assignment - SmartEduConnect</title>
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
        <a class="active" href="uploadAssignment.jsp">Upload Assignment</a>
        <a href="assignments.jsp">Assignments</a>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Upload Assignment</h2>
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
                    <h1>Create Assignment</h1>
                    <p>
                        Upload a new assignment for one of your assigned courses.
                        <% if (facultyName != null && !facultyName.isEmpty()) { %>
                            <br><span style="font-size:15px; color:#6b7280;"><b><%= facultyName %></b></span>
                        <% } %>
                    </p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="assignments.jsp">View Assignments</a>
                    <a class="btn btn-secondary" href="facultyDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Assignment Details</h3>
                <p class="card-subtitle">Fill in the details below to publish a new assignment.</p>

                <form method="post">
                    <div class="form-grid">

                        <div class="field">
                            <label>Assigned Course</label>
                            <select name="course_id" required>
                                <option value="">Select Course</option>
                                <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    Connection con = DriverManager.getConnection(URL, USER, PASS);

                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT c.course_id, c.course_code, c.course_name " +
                                        "FROM faculty_course fc " +
                                        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
                                        "JOIN course c ON fc.course_id = c.course_id " +
                                        "WHERE f.email=? " +
                                        "ORDER BY c.course_code"
                                    );
                                    ps.setString(1, email);
                                    ResultSet rs = ps.executeQuery();

                                    while (rs.next()) {
                                %>
                                    <option value="<%= rs.getInt("course_id") %>">
                                        <%= rs.getString("course_code") %> - <%= rs.getString("course_name") %>
                                    </option>
                                <%
                                    }

                                    rs.close();
                                    ps.close();
                                    con.close();
                                } catch (Exception e) {
                                %>
                                    <option value="">Error loading courses</option>
                                <%
                                }
                                %>
                            </select>
                        </div>

                        <div class="field">
                            <label>Title</label>
                            <input type="text" name="title" placeholder="Enter assignment title" required>
                        </div>

                        <div class="field">
                            <label>Due Date</label>
                            <input type="date" name="due_date" required>
                        </div>

                        <div class="field">
                            <label>Status</label>
                            <select name="status" required>
                                <option value="Pending">Pending</option>
                                <option value="Upcoming">Upcoming</option>
                                <option value="Submitted">Submitted</option>
                            </select>
                        </div>

                        <div class="field" style="grid-column: 1 / -1;">
                            <label>Description</label>
                            <textarea name="description" placeholder="Enter assignment description" required></textarea>
                        </div>

                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Upload Assignment</button>
                        <a class="btn btn-secondary" href="javascript:history.back()">Back</a>
                    </div>
                </form>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Faculty Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Faculty can upload assignments only for courses assigned to them. This keeps assignment workflows secure and course-specific.</p>
            </div>

        </div>
    </div>

</div>
</body>
</html>