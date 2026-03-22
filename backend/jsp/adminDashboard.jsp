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

int students = 0;
int faculty = 0;
int courses = 0;
int attendanceRecords = 0;
int marksRecords = 0;
int assignmentsCount = 0;
String errorMessage = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);
    Statement st = con.createStatement();

    ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM student");
    if (rs1.next()) students = rs1.getInt(1);
    rs1.close();

    ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM faculty");
    if (rs2.next()) faculty = rs2.getInt(1);
    rs2.close();

    ResultSet rs3 = st.executeQuery("SELECT COUNT(*) FROM course");
    if (rs3.next()) courses = rs3.getInt(1);
    rs3.close();

    ResultSet rs4 = st.executeQuery("SELECT COUNT(*) FROM attendance");
    if (rs4.next()) attendanceRecords = rs4.getInt(1);
    rs4.close();

    ResultSet rs5 = st.executeQuery("SELECT COUNT(*) FROM marks");
    if (rs5.next()) marksRecords = rs5.getInt(1);
    rs5.close();

    try {
        ResultSet rs6 = st.executeQuery("SELECT COUNT(*) FROM assignment");
        if (rs6.next()) assignmentsCount = rs6.getInt(1);
        rs6.close();
    } catch (Exception ex) {
        assignmentsCount = 0;
    }

    st.close();
    con.close();
} catch (Exception e) {
    errorMessage = "Database error: " + e.getMessage();
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="app">

    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge">Admin Panel</div>

        <div class="nav-section">Overview</div>
        <a class="active" href="adminDashboard.jsp">Dashboard</a>

        <div class="nav-section">Management</div>
        <a href="addStudent.jsp">Add Student</a>
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
            <h2>Admin Dashboard</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">

            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert-error"><%= errorMessage %></div>
            <% } %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Institution Control Center</h1>
                    <p>Oversee students, faculty, courses, assignments, attendance, and academic workflows from one centralized admin dashboard.</p>
                </div>

                <div class="page-actions">
                    <a class="btn" href="addStudent.jsp">Add Student</a>
                    <a class="btn btn-secondary" href="assignCourseFaculty.jsp">Assign Courses</a>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Total Students</div>
                    <div class="kpi-value"><%= students %></div>
                    <div class="kpi-subtext">Registered student profiles</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Total Faculty</div>
                    <div class="kpi-value"><%= faculty %></div>
                    <div class="kpi-subtext">Active teaching staff</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Total Courses</div>
                    <div class="kpi-value"><%= courses %></div>
                    <div class="kpi-subtext">Courses in the system</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Assignments Active</div>
                    <div class="kpi-value"><%= assignmentsCount %></div>
                    <div class="kpi-subtext">Published assignment records</div>
                </div>
            </div>

            <div class="dashboard-grid">
                <div class="stack">

                    <div class="card">
                        <h3 class="card-title">System Overview</h3>
                        <p class="card-subtitle">A consolidated snapshot of core academic activity across the platform.</p>

                        <div class="mini-grid">
                            <div class="module-card">
                                <h3>Attendance Activity</h3>
                                <p><b><%= attendanceRecords %></b> attendance record(s) are currently stored in the academic system.</p>
                            </div>

                            <div class="module-card">
                                <h3>Marks Workflow</h3>
                                <p><b><%= marksRecords %></b> marks record(s) are available across academic evaluations.</p>
                            </div>
                        </div>

                        <div class="form-actions">
                            <a class="btn" href="listStudents.jsp">Manage Students</a>
                            <a class="btn btn-secondary" href="listFaculty.jsp">Manage Faculty</a>
                            <a class="btn btn-secondary" href="listCourses.jsp">Manage Courses</a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Recent Administrative Notifications</h3>
                        <p class="card-subtitle">Institution-level updates and workflow checkpoints.</p>

                        <div class="list">
                            <div class="list-item">
                                <div class="list-item-title">Student and faculty records available</div>
                                <div class="list-item-meta">User data modules are ready for institutional monitoring and maintenance.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Course allocation module active</div>
                                <div class="list-item-meta">Faculty-course mappings can be created and reviewed through the allocation workflow.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Academic evaluation data present</div>
                                <div class="list-item-meta">Attendance and marks workflows are connected to course-level academic records.</div>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="stack">

                    <div class="card">
                        <h3 class="card-title">Administrative Priorities</h3>
                        <p class="card-subtitle">Key management responsibilities for the admin role.</p>

                        <ul class="info-points">
                            <li>Monitor student and faculty record accuracy.</li>
                            <li>Maintain course master data and course allocations.</li>
                            <li>Review attendance and marks workflow consistency.</li>
                            <li>Track assignment activity across the institution.</li>
                        </ul>

                        <div class="form-actions">
                            <a class="btn" href="listStudents.jsp">Students</a>
                            <a class="btn btn-secondary" href="listFaculty.jsp">Faculty</a>
                            <a class="btn btn-secondary" href="listCourses.jsp">Courses</a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Quick Access</h3>
                        <p class="card-subtitle">Jump directly into common administrative actions.</p>

                        <div class="quick-links">
                            <a class="quick-link" href="addStudent.jsp">
                                <h4>Add Student</h4>
                                <p>Create and register a new student record.</p>
                            </a>

                            <a class="quick-link" href="addFaculty.jsp">
                                <h4>Add Faculty</h4>
                                <p>Create and register a new faculty profile.</p>
                            </a>

                            <a class="quick-link" href="addCourse.jsp">
                                <h4>Add Course</h4>
                                <p>Introduce a new course into the academic system.</p>
                            </a>

                            <a class="quick-link" href="assignCourseFaculty.jsp">
                                <h4>Assign Courses</h4>
                                <p>Map courses to faculty members efficiently.</p>
                            </a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Admin Access Scope</h3>
                        <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                        <p>Admins have institution-level authority to manage students, faculty, courses, course allocations, and assignment visibility while monitoring attendance and marks workflows across the system.</p>
                    </div>

                </div>
            </div>
        </div>
    </div>

</div>
</body>
</html>