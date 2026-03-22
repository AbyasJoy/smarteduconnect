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
        int facultyId = Integer.parseInt(request.getParameter("faculty_id"));
        int courseId = Integer.parseInt(request.getParameter("course_id"));

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) FROM faculty_course WHERE faculty_id=? AND course_id=?"
        );
        psCheck.setInt(1, facultyId);
        psCheck.setInt(2, courseId);
        ResultSet rsCheck = psCheck.executeQuery();

        int alreadyAssigned = 0;
        if (rsCheck.next()) {
            alreadyAssigned = rsCheck.getInt(1);
        }
        rsCheck.close();
        psCheck.close();

        if (alreadyAssigned > 0) {
            errorMessage = "This course is already assigned to the selected faculty.";
        } else {
            PreparedStatement psInsert = con.prepareStatement(
                "INSERT INTO faculty_course (faculty_id, course_id) VALUES (?, ?)"
            );
            psInsert.setInt(1, facultyId);
            psInsert.setInt(2, courseId);
            psInsert.executeUpdate();
            psInsert.close();

            successMessage = "Course assigned successfully.";
        }

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
    <title>Assign Course to Faculty - SmartEduConnect</title>
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
            <h2>Assign Courses</h2>
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
                    <h1>Assign Course to Faculty</h1>
                    <p>Map academic courses to faculty members for attendance, marks, and assignment workflows.</p>
                </div>

                <div class="page-actions">
                    <a class="btn btn-secondary" href="listFaculty.jsp">View Faculty</a>
                    <a class="btn btn-secondary" href="listCourses.jsp">View Courses</a>
                    <a class="btn btn-secondary" href="adminDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Course Allocation</h3>
                <p class="card-subtitle">Select a faculty member and a course to create a valid allocation mapping.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Faculty</label>
                            <select name="faculty_id" required>
                                <option value="">Select Faculty</option>
                                <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    Connection con = DriverManager.getConnection(URL, USER, PASS);

                                    Statement stFaculty = con.createStatement();
                                    ResultSet rsFaculty = stFaculty.executeQuery(
                                        "SELECT faculty_id, faculty_name, department FROM faculty ORDER BY faculty_name"
                                    );

                                    while (rsFaculty.next()) {
                                %>
                                <option value="<%= rsFaculty.getInt("faculty_id") %>">
                                    <%= rsFaculty.getString("faculty_name") %> - <%= rsFaculty.getString("department") %>
                                </option>
                                <%
                                    }

                                    rsFaculty.close();
                                    stFaculty.close();
                                    con.close();
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
                                    Connection con = DriverManager.getConnection(URL, USER, PASS);

                                    Statement stCourse = con.createStatement();
                                    ResultSet rsCourse = stCourse.executeQuery(
                                        "SELECT course_id, course_code, course_name FROM course ORDER BY course_code"
                                    );

                                    while (rsCourse.next()) {
                                %>
                                <option value="<%= rsCourse.getInt("course_id") %>">
                                    <%= rsCourse.getString("course_code") %> - <%= rsCourse.getString("course_name") %>
                                </option>
                                <%
                                    }

                                    rsCourse.close();
                                    stCourse.close();
                                    con.close();
                                } catch (Exception e) {
                                %>
                                <option value="">Error loading courses</option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Assign Course</button>
                    </div>
                </form>
            </div>

            <div class="table-shell" style="margin-top:24px;">
                <div class="table-header">
                    <h3>Assigned Courses</h3>
                    <p>Current faculty-course mappings available in the system.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>Mapping ID</th>
                            <th>Faculty Name</th>
                            <th>Department</th>
                            <th>Course Code</th>
                            <th>Course Name</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>

<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery(
        "SELECT fc.fc_id, f.faculty_name, f.department, c.course_code, c.course_name " +
        "FROM faculty_course fc " +
        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
        "JOIN course c ON fc.course_id = c.course_id " +
        "ORDER BY fc.fc_id DESC"
    );

    boolean hasData = false;

    while (rs.next()) {
        hasData = true;
%>
                        <tr>
                            <td><%= rs.getInt("fc_id") %></td>
                            <td><%= rs.getString("faculty_name") %></td>
                            <td><%= rs.getString("department") %></td>
                            <td><b><%= rs.getString("course_code") %></b></td>
                            <td><%= rs.getString("course_name") %></td>
                            <td>
                                <a class="btn btn-secondary" href="updateFacultyCourse.jsp?id=<%= rs.getInt("fc_id") %>">Edit</a>
                            </td>
                            <td>
                                <a class="btn btn-danger"
                                   href="deleteFacultyCourse.jsp?id=<%= rs.getInt("fc_id") %>"
                                   onclick="return confirm('Delete this faculty-course mapping?');">Delete</a>
                            </td>
                        </tr>
<%
    }

    if (!hasData) {
%>
                        <tr>
                            <td colspan="7">No faculty-course mappings found.</td>
                        </tr>
<%
    }

    rs.close();
    st.close();
    con.close();

} catch (Exception e) {
%>
                        <tr>
                            <td colspan="7" style="color:red;">Error: <%= e.getMessage() %></td>
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
                <p>Admins can allocate, update, and remove courses assigned to faculty members. These mappings control faculty access for attendance, marks, assignments, and course-level academic workflows.</p>
            </div>

        </div>
    </div>

</div>
</body>
</html>