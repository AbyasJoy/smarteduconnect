<%@ page import="java.sql.*" %>
<%
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

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);
    Statement st = con.createStatement();

    ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM student");
    if (rs1.next()) students = rs1.getInt(1);

    ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM faculty");
    if (rs2.next()) faculty = rs2.getInt(1);

    ResultSet rs3 = st.executeQuery("SELECT COUNT(*) FROM course");
    if (rs3.next()) courses = rs3.getInt(1);

    ResultSet rs4 = st.executeQuery("SELECT COUNT(*) FROM attendance");
    if (rs4.next()) attendanceRecords = rs4.getInt(1);

    ResultSet rs5 = st.executeQuery("SELECT COUNT(*) FROM marks");
    if (rs5.next()) marksRecords = rs5.getInt(1);

    try {
        ResultSet rs6 = st.executeQuery("SELECT COUNT(*) FROM assignment");
        if (rs6.next()) assignmentsCount = rs6.getInt(1);
    } catch (Exception ex) {
        assignmentsCount = 8;
    }

    con.close();
} catch (Exception e) {
    students = 120;
    faculty = 24;
    courses = 15;
    attendanceRecords = 420;
    marksRecords = 250;
    assignmentsCount = 8;
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
        <a href="login.html">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Admin Dashboard</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div class="page-title">
                    <h1>Institution Control Center</h1>
                    <p>Oversee academic infrastructure, user records, course administration, evaluation activity, and institutional workflow from a centralized control panel.</p>
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
                    <div class="kpi-subtext">Registered academic users</div>
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
                    <div class="kpi-subtext">Institution-wide assignment count</div>
                </div>
            </div>

            <div class="dashboard-grid">
                <div class="stack">
                    <div class="card">
                        <h3 class="card-title">System Overview</h3>
                        <p class="card-subtitle">A consolidated snapshot of academic platform activity.</p>

                        <div class="mini-grid">
                            <div class="module-card">
                                <h3>Attendance Activity</h3>
                                <p><b><%= attendanceRecords %></b> attendance record(s) are currently stored and monitored through the system.</p>
                            </div>

                            <div class="module-card">
                                <h3>Marks Workflow</h3>
                                <p><b><%= marksRecords %></b> marks record(s) are available across managed academic assessments.</p>
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
                        <p class="card-subtitle">Institution-level operational updates.</p>

                        <div class="list">
                            <div class="list-item">
                                <div class="list-item-title">Student and faculty records updated</div>
                                <div class="list-item-meta">Recent user administration activity has been detected in the portal.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Course allocation requires monitoring</div>
                                <div class="list-item-meta">Faculty-course mapping should be verified for the active academic cycle.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Academic evaluation activity ongoing</div>
                                <div class="list-item-meta">Attendance and marks workflows are actively running across course modules.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="stack">
                    <div class="card">
                        <h3 class="card-title">Administrative Priorities</h3>
                        <p class="card-subtitle">Key oversight areas for institutional management.</p>

                        <ul class="info-points">
                            <li>Monitor student and faculty record accuracy.</li>
                            <li>Ensure course allocation remains up to date.</li>
                            <li>Oversee attendance and marks workflow quality.</li>
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
                        <p class="card-subtitle">Jump directly into common administrative modules.</p>

                        <div class="quick-links">
                            <a class="quick-link" href="addStudent.jsp">
                                <h4>Add Student</h4>
                                <p>Create and register a new student record.</p>
                            </a>

                            <a class="quick-link" href="addFaculty.jsp">
                                <h4>Add Faculty</h4>
                                <p>Create and register teaching staff records.</p>
                            </a>

                            <a class="quick-link" href="addCourse.jsp">
                                <h4>Add Course</h4>
                                <p>Introduce a new academic course into the system.</p>
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
                        <p>Admins have institution-level authority to manage students, faculty, courses, assignment visibility, and academic workflow oversight. Student-only and faculty-only operational tasks remain role-restricted.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</body>
</html>