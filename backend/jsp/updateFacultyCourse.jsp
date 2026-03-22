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

String idStr = request.getParameter("id");
if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("assignCourseFaculty.jsp");
    return;
}

int fcId = 0;
try {
    fcId = Integer.parseInt(idStr);
} catch (Exception e) {
    response.sendRedirect("assignCourseFaculty.jsp");
    return;
}

int selectedFacultyId = 0;
int selectedCourseId = 0;

Connection con = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int newFacultyId = Integer.parseInt(request.getParameter("faculty_id"));
        int newCourseId = Integer.parseInt(request.getParameter("course_id"));

        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) FROM faculty_course WHERE faculty_id=? AND course_id=? AND fc_id<>?"
        );
        psCheck.setInt(1, newFacultyId);
        psCheck.setInt(2, newCourseId);
        psCheck.setInt(3, fcId);
        ResultSet rsCheck = psCheck.executeQuery();

        int exists = 0;
        if (rsCheck.next()) {
            exists = rsCheck.getInt(1);
        }
        rsCheck.close();
        psCheck.close();

        if (exists > 0) {
            errorMessage = "This faculty-course mapping already exists.";
        } else {
            PreparedStatement psUpdate = con.prepareStatement(
                "UPDATE faculty_course SET faculty_id=?, course_id=? WHERE fc_id=?"
            );
            psUpdate.setInt(1, newFacultyId);
            psUpdate.setInt(2, newCourseId);
            psUpdate.setInt(3, fcId);
            psUpdate.executeUpdate();
            psUpdate.close();

            successMessage = "Faculty-course mapping updated successfully.";
        }
    }

    PreparedStatement psLoad = con.prepareStatement(
        "SELECT faculty_id, course_id FROM faculty_course WHERE fc_id=?"
    );
    psLoad.setInt(1, fcId);
    ResultSet rsLoad = psLoad.executeQuery();

    if (rsLoad.next()) {
        selectedFacultyId = rsLoad.getInt("faculty_id");
        selectedCourseId = rsLoad.getInt("course_id");
    } else {
        rsLoad.close();
        psLoad.close();
        con.close();
        response.sendRedirect("assignCourseFaculty.jsp");
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
    <title>Update Faculty Course Mapping - SmartEduConnect</title>
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
        <a href="listFaculty.jsp">Manage Faculty</a>
        <a href="addCourse.jsp">Add Course</a>
        <a href="listCourses.jsp">Manage Courses</a>
        <a class="active" href="assignCourseFaculty.jsp">Assign Courses</a>

        <div class="nav-section">Monitoring</div>
        <a href="assignments.jsp">Assignments Overview</a>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Update Course Assignment</h2>
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
                    <h1>Edit Faculty-Course Mapping</h1>
                    <p>Update the assigned course for a faculty member.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="assignCourseFaculty.jsp">Back to Assign Courses</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Update Mapping</h3>
                <p class="card-subtitle">Select the updated faculty and course combination below.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Faculty</label>
                            <select name="faculty_id" required>
                                <option value="">Select Faculty</option>
                                <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    Connection con2 = DriverManager.getConnection(URL, USER, PASS);

                                    Statement stFaculty = con2.createStatement();
                                    ResultSet rsFaculty = stFaculty.executeQuery(
                                        "SELECT faculty_id, faculty_name, department FROM faculty ORDER BY faculty_name"
                                    );

                                    while (rsFaculty.next()) {
                                        int fid = rsFaculty.getInt("faculty_id");
                                %>
                                <option value="<%= fid %>" <%= fid == selectedFacultyId ? "selected" : "" %>>
                                    <%= rsFaculty.getString("faculty_name") %> - <%= rsFaculty.getString("department") %>
                                </option>
                                <%
                                    }

                                    rsFaculty.close();
                                    stFaculty.close();
                                    con2.close();
                                } catch (Exception e) {
                                %>
                                <option value="">Error loading faculty</option>
                                <% } %>
                            </select>
                        </div>

                        <div class="field">
                            <label>Course</label>
                            <select name="course_id" required>
                                <option value="">Select Course</option>
                                <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    Connection con3 = DriverManager.getConnection(URL, USER, PASS);

                                    Statement stCourse = con3.createStatement();
                                    ResultSet rsCourse = stCourse.executeQuery(
                                        "SELECT course_id, course_code, course_name FROM course ORDER BY course_code"
                                    );

                                    while (rsCourse.next()) {
                                        int cid = rsCourse.getInt("course_id");
                                %>
                                <option value="<%= cid %>" <%= cid == selectedCourseId ? "selected" : "" %>>
                                    <%= rsCourse.getString("course_code") %> - <%= rsCourse.getString("course_name") %>
                                </option>
                                <%
                                    }

                                    rsCourse.close();
                                    stCourse.close();
                                    con3.close();
                                } catch (Exception e) {
                                %>
                                <option value="">Error loading course</option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Update Mapping</button>
                        <a class="btn btn-secondary" href="assignCourseFaculty.jsp">Cancel</a>
                    </div>
                </form>
            </div>

        </div>
    </div>

</div>
</body>
</html>