<%@ page import="java.sql.*" %>

<%
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
int studentId = 0;
String studentName = "";
int totalClasses = 0;
int presentClasses = 0;
int attendancePercent = 0;

/* ---------- FACULTY VARIABLES ---------- */
int facultyId = 0;
String facultyName = "";
int totalAttendanceRecords = 0;
int totalStudentsCovered = 0;

/* ---------- FACULTY SAVE ATTENDANCE ---------- */
if ("faculty".equalsIgnoreCase(role) && "POST".equalsIgnoreCase(request.getMethod())) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        int sid = Integer.parseInt(request.getParameter("student_id"));
        int cid = Integer.parseInt(request.getParameter("course_id"));
        java.sql.Date attDate = java.sql.Date.valueOf(request.getParameter("att_date"));
        String status = request.getParameter("status");

        // Find logged-in faculty
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

        // Check if selected course belongs to logged-in faculty
        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) FROM faculty_course WHERE faculty_id=? AND course_id=?"
        );
        psCheck.setInt(1, facultyId);
        psCheck.setInt(2, cid);
        ResultSet rsCheck = psCheck.executeQuery();

        int allowed = 0;
        if (rsCheck.next()) {
            allowed = rsCheck.getInt(1);
        }
        rsCheck.close();
        psCheck.close();

        if (allowed == 0) {
            throw new Exception("You can only manage attendance for your assigned courses.");
        }

        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO attendance (student_id, course_id, att_date, status) VALUES (?,?,?,?)"
        );
        ps.setInt(1, sid);
        ps.setInt(2, cid);
        ps.setDate(3, attDate);
        ps.setString(4, status);

        ps.executeUpdate();
        ps.close();
        con.close();

        successMessage = "Attendance saved successfully.";

    } catch (NumberFormatException nfe) {
        errorMessage = "Student ID and Course ID must be numeric values.";
    } catch (SQLIntegrityConstraintViolationException fk) {
        errorMessage = "Invalid Student ID or Course ID.";
    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
    }
}

/* ---------- STUDENT DATA ---------- */
if ("student".equalsIgnoreCase(role)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement ps = con.prepareStatement(
            "SELECT student_id, name FROM student WHERE email=?"
        );
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            studentId = rs.getInt("student_id");
            studentName = rs.getString("name");
        }
        rs.close();
        ps.close();

        if (studentId > 0) {
            PreparedStatement psTotal = con.prepareStatement(
                "SELECT COUNT(*) FROM attendance WHERE student_id=?"
            );
            psTotal.setInt(1, studentId);
            ResultSet rsTotal = psTotal.executeQuery();
            if (rsTotal.next()) totalClasses = rsTotal.getInt(1);
            rsTotal.close();
            psTotal.close();

            PreparedStatement psPresent = con.prepareStatement(
                "SELECT COUNT(*) FROM attendance WHERE student_id=? AND status='Present'"
            );
            psPresent.setInt(1, studentId);
            ResultSet rsPresent = psPresent.executeQuery();
            if (rsPresent.next()) presentClasses = rsPresent.getInt(1);
            rsPresent.close();
            psPresent.close();

            if (totalClasses > 0) {
                attendancePercent = (presentClasses * 100) / totalClasses;
            }
        }

        con.close();

    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
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
            PreparedStatement psRecords = con.prepareStatement(
                "SELECT COUNT(*) " +
                "FROM attendance a " +
                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                "WHERE fc.faculty_id = ?"
            );
            psRecords.setInt(1, facultyId);
            ResultSet rsRecords = psRecords.executeQuery();
            if (rsRecords.next()) totalAttendanceRecords = rsRecords.getInt(1);
            rsRecords.close();
            psRecords.close();

            PreparedStatement psStudents = con.prepareStatement(
                "SELECT COUNT(DISTINCT a.student_id) " +
                "FROM attendance a " +
                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                "WHERE fc.faculty_id = ?"
            );
            psStudents.setInt(1, facultyId);
            ResultSet rsStudents = psStudents.executeQuery();
            if (rsStudents.next()) totalStudentsCovered = rsStudents.getInt(1);
            rsStudents.close();
            psStudents.close();
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
<title>Attendance - SmartEduConnect</title>
<link rel="stylesheet" href="style.css">
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
        <% } %>

        <div class="nav-section">Academic</div>
        <% if ("student".equalsIgnoreCase(role)) { %>
            <a href="profile.jsp">My Profile</a>
            <a class="active" href="attendance.jsp">My Attendance</a>
            <a href="marks.jsp">My Marks</a>
            <a href="listCourses.jsp">Course Tracking</a>
            <a href="assignments.jsp">Assignments</a>
        <% } else if ("faculty".equalsIgnoreCase(role)) { %>
            <a href="listCourses.jsp">Assigned Courses</a>
            <a class="active" href="attendance.jsp">Manage Attendance</a>
            <a href="marks.jsp">Upload Marks</a>
            <a href="assignments.jsp">Assignments</a>
        <% } %>

        <div class="nav-section">Session</div>
        <a href="login.html">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Attendance</h2>
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
                    <h1>My Attendance</h1>
                    <p>
                        View your attendance across enrolled courses.
                        <% if(studentName != null && !studentName.isEmpty()) { %>
                        <br><span style="font-size:15px; color:#6b7280;"><b><%= studentName %></b></span>
                        <% } %>
                    </p>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Total Classes</div>
                    <div class="kpi-value"><%= totalClasses %></div>
                    <div class="kpi-subtext">Recorded sessions</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Present</div>
                    <div class="kpi-value"><%= presentClasses %></div>
                    <div class="kpi-subtext">Classes attended</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Absent</div>
                    <div class="kpi-value"><%= (totalClasses - presentClasses) %></div>
                    <div class="kpi-subtext">Missed sessions</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Attendance %</div>
                    <div class="kpi-value"><%= attendancePercent %>%</div>
                    <div class="kpi-subtext">Overall attendance</div>
                </div>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Attendance Records</h3>
                    <p>Your attendance entries by course.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Course</th>
                            <th>Date</th>
                            <th>Status</th>
                        </tr>

                        <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection con = DriverManager.getConnection(URL, USER, PASS);

                            PreparedStatement ps = con.prepareStatement(
                                "SELECT a.attendance_id, c.course_code, a.att_date, a.status " +
                                "FROM attendance a " +
                                "JOIN course c ON a.course_id = c.course_id " +
                                "WHERE a.student_id = ? " +
                                "ORDER BY a.att_date DESC"
                            );
                            ps.setInt(1, studentId);

                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getInt("attendance_id") %></td>
                            <td><%= rs.getString("course_code") %></td>
                            <td><%= rs.getDate("att_date") %></td>
                            <td>
                                <span class="status-badge <%= rs.getString("status").equals("Present") ? "status-good" : "status-bad" %>">
                                    <%= rs.getString("status") %>
                                </span>
                            </td>
                        </tr>
                        <%
                            }

                            rs.close();
                            ps.close();
                            con.close();

                        } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="4" style="color:red;">Error: <%= e.getMessage() %></td>
                        </tr>
                        <% } %>
                    </table>
                </div>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Student Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Students can only view attendance. Attendance creation and modification are restricted to faculty workflows.</p>
            </div>

            <% } %>

            <% if ("faculty".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Attendance Management</h1>
                    <p>
                        Record and monitor attendance only for your assigned courses.
                        <% if(facultyName != null && !facultyName.isEmpty()) { %>
                        <br><span style="font-size:15px; color:#6b7280;"><b><%= facultyName %></b></span>
                        <% } %>
                    </p>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Attendance Records</div>
                    <div class="kpi-value"><%= totalAttendanceRecords %></div>
                    <div class="kpi-subtext">Stored for your courses</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Students Covered</div>
                    <div class="kpi-value"><%= totalStudentsCovered %></div>
                    <div class="kpi-subtext">Distinct students in your courses</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Access Scope</div>
                    <div class="kpi-value">Assigned</div>
                    <div class="kpi-subtext">Only mapped courses</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Role</div>
                    <div class="kpi-value">Faculty</div>
                    <div class="kpi-subtext">Attendance control enabled</div>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Mark Attendance</h3>
                <p class="card-subtitle">Attendance can only be saved for your assigned courses.</p>

                <form method="post">
                    <div class="form-grid">
                        <div class="field">
                            <label>Student ID</label>
                            <input type="number" name="student_id" required>
                        </div>

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

                                } catch (Exception e) {
                                %>
                                <option value="">Error loading courses</option>
                                <% } %>
                            </select>
                        </div>

                        <div class="field">
                            <label>Date</label>
                            <input type="date" name="att_date" required>
                        </div>

                        <div class="field">
                            <label>Status</label>
                            <select name="status" required>
                                <option value="Present">Present</option>
                                <option value="Absent">Absent</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Save Attendance</button>
                    </div>
                </form>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Attendance Records for Your Courses</h3>
                    <p>You can view attendance only for the courses assigned to you.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Student Name</th>
                            <th>Roll No</th>
                            <th>Course</th>
                            <th>Date</th>
                            <th>Status</th>
                        </tr>

                        <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection con = DriverManager.getConnection(URL, USER, PASS);

                            PreparedStatement ps = con.prepareStatement(
                                "SELECT a.attendance_id, s.name, s.roll_no, c.course_code, a.att_date, a.status " +
                                "FROM attendance a " +
                                "JOIN student s ON a.student_id = s.student_id " +
                                "JOIN course c ON a.course_id = c.course_id " +
                                "JOIN faculty_course fc ON a.course_id = fc.course_id " +
                                "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
                                "WHERE f.email = ? " +
                                "ORDER BY a.attendance_id DESC"
                            );
                            ps.setString(1, email);

                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getInt("attendance_id") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td><%= rs.getString("roll_no") %></td>
                            <td><%= rs.getString("course_code") %></td>
                            <td><%= rs.getDate("att_date") %></td>
                            <td>
                                <span class="status-badge <%= rs.getString("status").equals("Present") ? "status-good" : "status-bad" %>">
                                    <%= rs.getString("status") %>
                                </span>
                            </td>
                        </tr>
                        <%
                            }

                            rs.close();
                            ps.close();
                            con.close();

                        } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="6" style="color:red;">Error: <%= e.getMessage() %></td>
                        </tr>
                        <% } %>
                    </table>
                </div>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Faculty Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Faculty can create attendance records and monitor attendance only for their assigned courses. Student attendance remains view-only on the student side.</p>
            </div>

            <% } %>

        </div>
    </div>

</div>
</body>
</html>