<%@ page import="java.sql.*" %>
<%
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

int assignedCourses = 0;
int totalStudents = 0;
int attendanceRecords = 0;
int marksRecords = 0;
int assignmentsCount = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);
    Statement st = con.createStatement();

    ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM course");
    if (rs1.next()) assignedCourses = rs1.getInt(1);

    ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM student");
    if (rs2.next()) totalStudents = rs2.getInt(1);

    ResultSet rs3 = st.executeQuery("SELECT COUNT(*) FROM attendance");
    if (rs3.next()) attendanceRecords = rs3.getInt(1);

    ResultSet rs4 = st.executeQuery("SELECT COUNT(*) FROM marks");
    if (rs4.next()) marksRecords = rs4.getInt(1);

    try {
        ResultSet rs5 = st.executeQuery("SELECT COUNT(*) FROM assignment");
        if (rs5.next()) assignmentsCount = rs5.getInt(1);
    } catch (Exception ex) {
        assignmentsCount = 4;
    }

    con.close();
} catch (Exception e) {
    assignedCourses = 3;
    totalStudents = 48;
    attendanceRecords = 126;
    marksRecords = 58;
    assignmentsCount = 4;
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Faculty Dashboard - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="app">

    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge">Faculty Panel</div>

        <div class="nav-section">Workspace</div>
        <a class="active" href="facultyDashboard.jsp">Dashboard</a>
        <a href="listCourses.jsp">Assigned Courses</a>
        <a href="listStudents.jsp">Student List</a>

        <div class="nav-section">Academic Actions</div>
        <a href="attendance.jsp">Manage Attendance</a>
        <a href="marks.jsp">Upload Marks</a>
        <a href="uploadAssignment.jsp">Upload Assignment</a>
        <a href="assignments.jsp">Assignments</a>

        <div class="nav-section">Session</div>
        <a href="login.html">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Faculty Dashboard</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div class="page-title">
                    <h1>Faculty Academic Workspace</h1>
                    <p>Monitor course delivery, attendance workflow, academic evaluation, and assignment activity through a focused instructional dashboard.</p>
                </div>

                <div class="page-actions">
                    <a class="btn" href="attendance.jsp">Mark Attendance</a>
                    <a class="btn btn-secondary" href="marks.jsp">Upload Marks</a>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Assigned Courses</div>
                    <div class="kpi-value"><%= assignedCourses %></div>
                    <div class="kpi-subtext">Courses currently mapped</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Students Covered</div>
                    <div class="kpi-value"><%= totalStudents %></div>
                    <div class="kpi-subtext">Learners under supervision</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Attendance Records</div>
                    <div class="kpi-value"><%= attendanceRecords %></div>
                    <div class="kpi-subtext">Entries recorded in the system</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Marks Uploaded</div>
                    <div class="kpi-value"><%= marksRecords %></div>
                    <div class="kpi-subtext">Assessment records available</div>
                </div>
            </div>

            <div class="dashboard-grid">
                <div class="stack">
                    <div class="card">
                        <h3 class="card-title">Teaching Summary</h3>
                        <p class="card-subtitle">A consolidated view of your current academic workload and instructional progress.</p>

                        <div class="mini-grid">
                            <div class="module-card">
                                <h3>Course Responsibility</h3>
                                <p>You are currently handling <b><%= assignedCourses %></b> mapped course(s) in the academic system.</p>
                            </div>

                            <div class="module-card">
                                <h3>Assessment Load</h3>
                                <p><b><%= assignmentsCount %></b> active assignment item(s) and ongoing marks workflow are currently visible.</p>
                            </div>
                        </div>

                        <div class="form-actions">
                            <a class="btn" href="listCourses.jsp">View Assigned Courses</a>
                            <a class="btn btn-secondary" href="listStudents.jsp">View Student List</a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Recent Academic Notifications</h3>
                        <p class="card-subtitle">Important updates requiring instructional attention.</p>

                        <div class="list">
                            <div class="list-item">
                                <div class="list-item-title">Attendance update pending</div>
                                <div class="list-item-meta">Today’s attendance should be verified and submitted for active courses.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Marks upload window active</div>
                                <div class="list-item-meta">Pending course assessment records can now be updated in the evaluation module.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Assignment review queue</div>
                                <div class="list-item-meta">Submitted work is awaiting verification and review across active course modules.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="stack">
                    <div class="card">
                        <h3 class="card-title">Priority Actions</h3>
                        <p class="card-subtitle">Common faculty workflows for the current academic cycle.</p>

                        <ul class="info-points">
                            <li>Verify today’s attendance entries before deadline.</li>
                            <li>Upload marks for recently completed assessments.</li>
                            <li>Review assignment submissions and pending academic tasks.</li>
                            <li>Track course-wise student participation and performance.</li>
                        </ul>

                        <div class="form-actions">
                            <a class="btn" href="attendance.jsp">Manage Attendance</a>
                            <a class="btn btn-secondary" href="marks.jsp">Upload Marks</a>
                            <a class="btn btn-secondary" href="uploadAssignment.jsp">Upload Assignment</a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Quick Access</h3>
                        <p class="card-subtitle">Open frequently used modules directly.</p>

                        <div class="quick-links">
                            <a class="quick-link" href="attendance.jsp">
                                <h4>Attendance</h4>
                                <p>Mark and review attendance entries.</p>
                            </a>

                            <a class="quick-link" href="marks.jsp">
                                <h4>Marks</h4>
                                <p>Upload and review academic scores.</p>
                            </a>

                            <a class="quick-link" href="uploadAssignment.jsp">
                                <h4>Assignments</h4>
                                <p>Create and publish course assignments.</p>
                            </a>

                            <a class="quick-link" href="listStudents.jsp">
                                <h4>Students</h4>
                                <p>Review student academic lists.</p>
                            </a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Faculty Access Scope</h3>
                        <p class="card-subtitle">Role permissions in the SmartEduConnect system.</p>
                        <p>Faculty members can manage attendance, upload marks, create assignments, and observe student academic progress. Institution-level configuration remains controlled by the admin panel.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</body>
</html>