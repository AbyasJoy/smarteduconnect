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

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

String successMessage = "";
String errorMessage = "";

/* ---------- STUDENT VARIABLES ---------- */
String studentName = "";
String rollNo = "";
int studentId = 0;

/* ---------- FACULTY VARIABLES ---------- */
int facultyId = 0;
String facultyName = "";
int assignedCourseCount = 0;

/* ---------- COMMON COUNTS ---------- */
int totalAssignments = 0;
int pendingAssignments = 0;
int submittedAssignments = 0;
int upcomingAssignments = 0;

/* ---------- FACULTY CREATE ASSIGNMENT ---------- */
if ("faculty".equalsIgnoreCase(role) && "POST".equalsIgnoreCase(request.getMethod())) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        int courseId = Integer.parseInt(request.getParameter("course_id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        java.sql.Date dueDate = java.sql.Date.valueOf(request.getParameter("due_date"));
        String status = request.getParameter("status");

        PreparedStatement psFaculty = con.prepareStatement(
            "SELECT faculty_id, faculty_name FROM faculty WHERE email=?"
        );
        psFaculty.setString(1, email);
        ResultSet rsFaculty = psFaculty.executeQuery();

        if (rsFaculty.next()) {
            facultyId = rsFaculty.getInt("faculty_id");
            facultyName = rsFaculty.getString("faculty_name");
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
            throw new Exception("You can only create assignments for your assigned courses.");
        }

        PreparedStatement psInsert = con.prepareStatement(
            "INSERT INTO assignment (course_id, title, description, due_date, status) VALUES (?,?,?,?,?)"
        );
        psInsert.setInt(1, courseId);
        psInsert.setString(2, title);
        psInsert.setString(3, description);
        psInsert.setDate(4, dueDate);
        psInsert.setString(5, status);
        psInsert.executeUpdate();

        psInsert.close();
        con.close();

        successMessage = "Assignment created successfully.";

    } catch (NumberFormatException nfe) {
        errorMessage = "Course ID must be numeric.";
    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
    }
}

/* ---------- STUDENT DATA ---------- */
if ("student".equalsIgnoreCase(role)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement psStudent = con.prepareStatement(
            "SELECT student_id, name, roll_no FROM student WHERE email=?"
        );
        psStudent.setString(1, email);
        ResultSet rsStudent = psStudent.executeQuery();

        if (rsStudent.next()) {
            studentId = rsStudent.getInt("student_id");
            studentName = rsStudent.getString("name");
            rollNo = rsStudent.getString("roll_no");
        }

        rsStudent.close();
        psStudent.close();

        PreparedStatement psTotal = con.prepareStatement("SELECT COUNT(*) FROM assignment");
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) totalAssignments = rsTotal.getInt(1);
        rsTotal.close();
        psTotal.close();

        PreparedStatement psPending = con.prepareStatement("SELECT COUNT(*) FROM assignment WHERE status='Pending'");
        ResultSet rsPending = psPending.executeQuery();
        if (rsPending.next()) pendingAssignments = rsPending.getInt(1);
        rsPending.close();
        psPending.close();

        PreparedStatement psSubmitted = con.prepareStatement("SELECT COUNT(*) FROM assignment WHERE status='Submitted'");
        ResultSet rsSubmitted = psSubmitted.executeQuery();
        if (rsSubmitted.next()) submittedAssignments = rsSubmitted.getInt(1);
        rsSubmitted.close();
        psSubmitted.close();

        PreparedStatement psUpcoming = con.prepareStatement("SELECT COUNT(*) FROM assignment WHERE status='Upcoming'");
        ResultSet rsUpcoming = psUpcoming.executeQuery();
        if (rsUpcoming.next()) upcomingAssignments = rsUpcoming.getInt(1);
        rsUpcoming.close();
        psUpcoming.close();

        con.close();

    } catch (Exception e) {
        errorMessage = "DB Error: " + e.getMessage();
    }
}

/* ---------- FACULTY DATA ---------- */
if ("faculty".equalsIgnoreCase(role)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement psFaculty = con.prepareStatement(
            "SELECT faculty_id, faculty_name FROM faculty WHERE email=?"
        );
        psFaculty.setString(1, email);
        ResultSet rsFaculty = psFaculty.executeQuery();

        if (rsFaculty.next()) {
            facultyId = rsFaculty.getInt("faculty_id");
            facultyName = rsFaculty.getString("faculty_name");
        }
        rsFaculty.close();
        psFaculty.close();

        if (facultyId > 0) {
            PreparedStatement psAssigned = con.prepareStatement(
                "SELECT COUNT(*) FROM faculty_course WHERE faculty_id=?"
            );
            psAssigned.setInt(1, facultyId);
            ResultSet rsAssigned = psAssigned.executeQuery();
            if (rsAssigned.next()) assignedCourseCount = rsAssigned.getInt(1);
            rsAssigned.close();
            psAssigned.close();

            PreparedStatement psTotal = con.prepareStatement(
                "SELECT COUNT(*) " +
                "FROM assignment a " +
                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                "WHERE fc.faculty_id=?"
            );
            psTotal.setInt(1, facultyId);
            ResultSet rsTotal = psTotal.executeQuery();
            if (rsTotal.next()) totalAssignments = rsTotal.getInt(1);
            rsTotal.close();
            psTotal.close();

            PreparedStatement psPending = con.prepareStatement(
                "SELECT COUNT(*) " +
                "FROM assignment a " +
                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                "WHERE fc.faculty_id=? AND a.status='Pending'"
            );
            psPending.setInt(1, facultyId);
            ResultSet rsPending = psPending.executeQuery();
            if (rsPending.next()) pendingAssignments = rsPending.getInt(1);
            rsPending.close();
            psPending.close();

            PreparedStatement psSubmitted = con.prepareStatement(
                "SELECT COUNT(*) " +
                "FROM assignment a " +
                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                "WHERE fc.faculty_id=? AND a.status='Submitted'"
            );
            psSubmitted.setInt(1, facultyId);
            ResultSet rsSubmitted = psSubmitted.executeQuery();
            if (rsSubmitted.next()) submittedAssignments = rsSubmitted.getInt(1);
            rsSubmitted.close();
            psSubmitted.close();

            PreparedStatement psUpcoming = con.prepareStatement(
                "SELECT COUNT(*) " +
                "FROM assignment a " +
                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                "WHERE fc.faculty_id=? AND a.status='Upcoming'"
            );
            psUpcoming.setInt(1, facultyId);
            ResultSet rsUpcoming = psUpcoming.executeQuery();
            if (rsUpcoming.next()) upcomingAssignments = rsUpcoming.getInt(1);
            rsUpcoming.close();
            psUpcoming.close();
        }

        con.close();

    } catch (Exception e) {
        errorMessage = "DB Error: " + e.getMessage();
    }
}

/* ---------- ADMIN DATA ---------- */
if ("admin".equalsIgnoreCase(role)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement psTotal = con.prepareStatement("SELECT COUNT(*) FROM assignment");
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) totalAssignments = rsTotal.getInt(1);
        rsTotal.close();
        psTotal.close();

        PreparedStatement psPending = con.prepareStatement("SELECT COUNT(*) FROM assignment WHERE status='Pending'");
        ResultSet rsPending = psPending.executeQuery();
        if (rsPending.next()) pendingAssignments = rsPending.getInt(1);
        rsPending.close();
        psPending.close();

        PreparedStatement psSubmitted = con.prepareStatement("SELECT COUNT(*) FROM assignment WHERE status='Submitted'");
        ResultSet rsSubmitted = psSubmitted.executeQuery();
        if (rsSubmitted.next()) submittedAssignments = rsSubmitted.getInt(1);
        rsSubmitted.close();
        psSubmitted.close();

        PreparedStatement psUpcoming = con.prepareStatement("SELECT COUNT(*) FROM assignment WHERE status='Upcoming'");
        ResultSet rsUpcoming = psUpcoming.executeQuery();
        if (rsUpcoming.next()) upcomingAssignments = rsUpcoming.getInt(1);
        rsUpcoming.close();
        psUpcoming.close();

        con.close();

    } catch (Exception e) {
        errorMessage = "DB Error: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assignments - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .assign-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .assign-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 22px;
        }

        .assign-title {
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .assign-meta {
            color: var(--muted);
            font-size: 14px;
            margin-bottom: 14px;
        }

        .assign-status {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 14px;
        }

        .assign-status.pending {
            background: #fef3c7;
            color: #92400e;
        }

        .assign-status.submitted {
            background: #dcfce7;
            color: #166534;
        }

        .assign-status.upcoming {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .assign-summary-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 24px;
        }

        .assign-summary-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 22px;
        }

        .assign-summary-card h4 {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
        }

        .assign-summary-card .big {
            font-size: 34px;
            font-weight: 800;
            margin-top: 10px;
        }

        .assign-actions {
            margin-top: 16px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        @media (max-width: 900px) {
            .assign-grid,
            .assign-summary-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="app">

    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge"><%= role %> Panel</div>

        <div class="nav-section">Overview</div>
        <% if ("student".equalsIgnoreCase(role)) { %>
            <a href="studentDashboard.jsp">Dashboard</a>
        <% } else if ("faculty".equalsIgnoreCase(role)) { %>
            <a href="facultyDashboard.jsp">Dashboard</a>
        <% } else if ("admin".equalsIgnoreCase(role)) { %>
            <a href="adminDashboard.jsp">Dashboard</a>
        <% } %>

        <div class="nav-section">Academic</div>
        <% if ("student".equalsIgnoreCase(role)) { %>
            <a href="profile.jsp">My Profile</a>
            <a href="attendance.jsp">My Attendance</a>
            <a href="marks.jsp">My Marks</a>
            <a href="listCourses.jsp">Course Tracking</a>
            <a class="active" href="assignments.jsp">Assignments</a>
        <% } else if ("faculty".equalsIgnoreCase(role)) { %>
            <a href="listCourses.jsp">Assigned Courses</a>
            <a href="attendance.jsp">Manage Attendance</a>
            <a href="marks.jsp">Upload Marks</a>
            <a class="active" href="assignments.jsp">Assignments</a>
        <% } else if ("admin".equalsIgnoreCase(role)) { %>
            <a href="addStudent.jsp">Add Student</a>
            <a href="listStudents.jsp">Manage Students</a>
            <a href="addFaculty.jsp">Add Faculty</a>
            <a href="listFaculty.jsp">Manage Faculty</a>
            <a href="addCourse.jsp">Add Course</a>
            <a href="listCourses.jsp">Manage Courses</a>
            <a href="assignCourseFaculty.jsp">Assign Courses</a>
            <a class="active" href="assignments.jsp">Assignments Overview</a>
        <% } %>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Assignments</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">

            <% if (!successMessage.isEmpty()) { %>
                <div class="alert-success"><%= successMessage %></div>
            <% } %>

            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert-error"><%= errorMessage %></div>
            <% } %>

            <% if ("student".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Assignment Tracking</h1>
                    <p>
                        Track academic tasks, notices, and pending coursework.
                        <% if(studentName != null && !studentName.isEmpty()) { %>
                        <br><span style="font-size:15px; color:#6b7280;"><b><%= studentName %></b> | <%= rollNo %></span>
                        <% } %>
                    </p>
                </div>
            </div>

            <div class="assign-summary-grid">
                <div class="assign-summary-card">
                    <h4>Total Assignments</h4>
                    <div class="big"><%= totalAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Pending</h4>
                    <div class="big"><%= pendingAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Submitted</h4>
                    <div class="big"><%= submittedAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Upcoming</h4>
                    <div class="big"><%= upcomingAssignments %></div>
                </div>
            </div>

            <div class="assign-grid">
<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement ps = con.prepareStatement(
        "SELECT a.assignment_id, a.title, a.description, a.due_date, a.status, c.course_code, c.course_name " +
        "FROM assignment a " +
        "JOIN course c ON a.course_id = c.course_id " +
        "ORDER BY a.due_date ASC"
    );

    ResultSet rs = ps.executeQuery();
    boolean hasData = false;

    while (rs.next()) {
        hasData = true;
        String status = rs.getString("status");
        String statusClass = "pending";
        if ("Submitted".equalsIgnoreCase(status)) statusClass = "submitted";
        else if ("Upcoming".equalsIgnoreCase(status)) statusClass = "upcoming";
%>
                <div class="assign-card">
                    <div class="assign-status <%= statusClass %>"><%= status %></div>
                    <div class="assign-title"><%= rs.getString("title") %></div>
                    <div class="assign-meta">
                        Course: <b><%= rs.getString("course_code") %></b> - <%= rs.getString("course_name") %><br>
                        Due: <b><%= rs.getDate("due_date") %></b>
                    </div>
                    <p><%= rs.getString("description") %></p>
                </div>
<%
    }

    if (!hasData) {
%>
                <div class="assign-card">
                    <div class="assign-title">No Assignments Available</div>
                    <p>No assignment records are available right now.</p>
                </div>
<%
    }

    rs.close();
    ps.close();
    con.close();

} catch (Exception e) {
%>
                <div class="assign-card">
                    <div class="assign-title">Error Loading Assignments</div>
                    <p style="color:red;"><%= e.getMessage() %></p>
                </div>
<%
}
%>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Student Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Students can review assignment notices and pending academic tasks. Assignment creation and publishing are reserved for faculty and admin workflows.</p>
            </div>

            <% } %>

            <% if ("faculty".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Assignments Management</h1>
                    <p>
                        Create, update, delete, and manage assignments only for your assigned courses.
                        <% if(facultyName != null && !facultyName.isEmpty()) { %>
                        <br><span style="font-size:15px; color:#6b7280;"><b><%= facultyName %></b></span>
                        <% } %>
                    </p>
                </div>
            </div>

            <div class="assign-summary-grid">
                <div class="assign-summary-card">
                    <h4>Total Assignments</h4>
                    <div class="big"><%= totalAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Pending</h4>
                    <div class="big"><%= pendingAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Submitted</h4>
                    <div class="big"><%= submittedAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Assigned Courses</h4>
                    <div class="big"><%= assignedCourseCount %></div>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Create Assignment</h3>
                <p class="card-subtitle">Assignments can only be created for the courses assigned to you.</p>

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

                                    PreparedStatement psCourses = con.prepareStatement(
                                        "SELECT c.course_id, c.course_code, c.course_name " +
                                        "FROM faculty_course fc " +
                                        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
                                        "JOIN course c ON fc.course_id = c.course_id " +
                                        "WHERE f.email = ? " +
                                        "ORDER BY c.course_id"
                                    );
                                    psCourses.setString(1, email);
                                    ResultSet rsCourses = psCourses.executeQuery();

                                    while (rsCourses.next()) {
                                %>
                                <option value="<%= rsCourses.getInt("course_id") %>">
                                    <%= rsCourses.getString("course_code") %> - <%= rsCourses.getString("course_name") %>
                                </option>
                                <%
                                    }

                                    rsCourses.close();
                                    psCourses.close();
                                    con.close();
                                } catch (Exception ex) {
                                %>
                                <option value="">Error loading courses</option>
                                <%
                                }
                                %>
                            </select>
                        </div>

                        <div class="field">
                            <label>Title</label>
                            <input type="text" name="title" required>
                        </div>

                        <div class="field">
                            <label>Due Date</label>
                            <input type="date" name="due_date" required>
                        </div>

                        <div class="field">
                            <label>Status</label>
                            <select name="status" required>
                                <option value="Pending">Pending</option>
                                <option value="Submitted">Submitted</option>
                                <option value="Upcoming">Upcoming</option>
                            </select>
                        </div>

                        <div class="field" style="grid-column: 1 / -1;">
                            <label>Description</label>
                            <textarea name="description" required></textarea>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Create Assignment</button>
                    </div>
                </form>
            </div>

            <div style="height:24px;"></div>

            <div class="assign-grid">
<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement ps = con.prepareStatement(
        "SELECT a.assignment_id, a.title, a.description, a.due_date, a.status, c.course_code, c.course_name " +
        "FROM assignment a " +
        "JOIN faculty_course fc ON a.course_id = fc.course_id " +
        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
        "JOIN course c ON a.course_id = c.course_id " +
        "WHERE f.email = ? " +
        "ORDER BY a.due_date ASC"
    );
    ps.setString(1, email);

    ResultSet rs = ps.executeQuery();
    boolean hasData = false;

    while (rs.next()) {
        hasData = true;
        String status = rs.getString("status");
        String statusClass = "pending";
        if ("Submitted".equalsIgnoreCase(status)) statusClass = "submitted";
        else if ("Upcoming".equalsIgnoreCase(status)) statusClass = "upcoming";
%>
                <div class="assign-card">
                    <div class="assign-status <%= statusClass %>"><%= status %></div>
                    <div class="assign-title"><%= rs.getString("title") %></div>
                    <div class="assign-meta">
                        Course: <b><%= rs.getString("course_code") %></b> - <%= rs.getString("course_name") %><br>
                        Due: <b><%= rs.getDate("due_date") %></b>
                    </div>
                    <p><%= rs.getString("description") %></p>

                    <div class="assign-actions">
                        <a class="btn btn-secondary" href="updateAssignment.jsp?id=<%= rs.getInt("assignment_id") %>">Edit</a>
                        <a class="btn btn-danger"
                           href="deleteAssignment.jsp?id=<%= rs.getInt("assignment_id") %>"
                           onclick="return confirm('Delete this assignment?');">Delete</a>
                    </div>
                </div>
<%
    }

    if (!hasData) {
%>
                <div class="assign-card">
                    <div class="assign-title">No Assignments Available</div>
                    <p>No assignments are mapped to your assigned courses yet.</p>
                </div>
<%
    }

    rs.close();
    ps.close();
    con.close();

} catch (Exception e) {
%>
                <div class="assign-card">
                    <div class="assign-title">Error Loading Assignments</div>
                    <p style="color:red;"><%= e.getMessage() %></p>
                </div>
<%
}
%>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Faculty Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Faculty can create, update, delete, and manage assignments only for their assigned courses. Institution-wide academic control remains restricted to admin workflows.</p>
            </div>

            <% } %>

            <% if ("admin".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Assignments Overview</h1>
                    <p>View and monitor all assignments across the academic portal.</p>
                </div>
            </div>

            <div class="assign-summary-grid">
                <div class="assign-summary-card">
                    <h4>Total Assignments</h4>
                    <div class="big"><%= totalAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Pending</h4>
                    <div class="big"><%= pendingAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Submitted</h4>
                    <div class="big"><%= submittedAssignments %></div>
                </div>

                <div class="assign-summary-card">
                    <h4>Upcoming</h4>
                    <div class="big"><%= upcomingAssignments %></div>
                </div>
            </div>

            <div class="assign-grid">
<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement ps = con.prepareStatement(
        "SELECT a.assignment_id, a.title, a.description, a.due_date, a.status, c.course_code, c.course_name " +
        "FROM assignment a " +
        "JOIN course c ON a.course_id = c.course_id " +
        "ORDER BY a.due_date ASC"
    );

    ResultSet rs = ps.executeQuery();
    boolean hasData = false;

    while (rs.next()) {
        hasData = true;
        String status = rs.getString("status");
        String statusClass = "pending";
        if ("Submitted".equalsIgnoreCase(status)) statusClass = "submitted";
        else if ("Upcoming".equalsIgnoreCase(status)) statusClass = "upcoming";
%>
                <div class="assign-card">
                    <div class="assign-status <%= statusClass %>"><%= status %></div>
                    <div class="assign-title"><%= rs.getString("title") %></div>
                    <div class="assign-meta">
                        Course: <b><%= rs.getString("course_code") %></b> - <%= rs.getString("course_name") %><br>
                        Due: <b><%= rs.getDate("due_date") %></b>
                    </div>
                    <p><%= rs.getString("description") %></p>
                </div>
<%
    }

    if (!hasData) {
%>
                <div class="assign-card">
                    <div class="assign-title">No Assignments Available</div>
                    <p>No assignment records are available in the system yet.</p>
                </div>
<%
    }

    rs.close();
    ps.close();
    con.close();

} catch (Exception e) {
%>
                <div class="assign-card">
                    <div class="assign-title">Error Loading Assignments</div>
                    <p style="color:red;"><%= e.getMessage() %></p>
                </div>
<%
}
%>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Admin Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Admins can monitor assignment activity across all courses and departments. Assignment creation is handled by faculty for assigned courses, while admins retain institution-wide oversight.</p>
            </div>

            <% } %>

        </div>
    </div>

</div>
</body>
</html>