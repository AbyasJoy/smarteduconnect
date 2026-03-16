<%@ page import="java.sql.*" %>
<%
String role = (String) session.getAttribute("role");
String email = (String) session.getAttribute("email");

if (role == null || email == null) {
    response.sendRedirect("login.html");
    return;
}

if (!"student".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

int studentId = 0;
String studentName = "";
String rollNo = "";
String department = "";
int year = 0;

int totalCourses = 0;
int activeAssignments = 0;
int attendancePercent = 0;
int marksUpdated = 0;
int totalClasses = 0;
int presentClasses = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement psStudent = con.prepareStatement(
        "SELECT student_id, roll_no, name, email, department, year FROM student WHERE email=?"
    );
    psStudent.setString(1, email);
    ResultSet rsStudent = psStudent.executeQuery();

    if (rsStudent.next()) {
        studentId = rsStudent.getInt("student_id");
        rollNo = rsStudent.getString("roll_no");
        studentName = rsStudent.getString("name");
        department = rsStudent.getString("department");
        year = rsStudent.getInt("year");
    }
    rsStudent.close();
    psStudent.close();

    if (studentId > 0) {
        PreparedStatement psCourses = con.prepareStatement(
            "SELECT COUNT(DISTINCT course_id) AS total_courses " +
            "FROM (" +
            "  SELECT course_id FROM attendance WHERE student_id=? " +
            "  UNION " +
            "  SELECT course_id FROM marks WHERE student_id=? " +
            ") t"
        );
        psCourses.setInt(1, studentId);
        psCourses.setInt(2, studentId);
        ResultSet rsCourses = psCourses.executeQuery();
        if (rsCourses.next()) {
            totalCourses = rsCourses.getInt("total_courses");
        }
        rsCourses.close();
        psCourses.close();

        PreparedStatement psTotal = con.prepareStatement(
            "SELECT COUNT(*) AS total_classes FROM attendance WHERE student_id=?"
        );
        psTotal.setInt(1, studentId);
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) {
            totalClasses = rsTotal.getInt("total_classes");
        }
        rsTotal.close();
        psTotal.close();

        PreparedStatement psPresent = con.prepareStatement(
            "SELECT COUNT(*) AS present_classes FROM attendance WHERE student_id=? AND status='Present'"
        );
        psPresent.setInt(1, studentId);
        ResultSet rsPresent = psPresent.executeQuery();
        if (rsPresent.next()) {
            presentClasses = rsPresent.getInt("present_classes");
        }
        rsPresent.close();
        psPresent.close();

        if (totalClasses > 0) {
            attendancePercent = (presentClasses * 100) / totalClasses;
        }

        PreparedStatement psMarks = con.prepareStatement(
            "SELECT COUNT(*) AS marks_count FROM marks WHERE student_id=?"
        );
        psMarks.setInt(1, studentId);
        ResultSet rsMarks = psMarks.executeQuery();
        if (rsMarks.next()) {
            marksUpdated = rsMarks.getInt("marks_count");
        }
        rsMarks.close();
        psMarks.close();

        // Optional: real assignment count if assignment table exists
        try {
            PreparedStatement psAssignments = con.prepareStatement(
                "SELECT COUNT(*) AS assignment_count " +
                "FROM assignment a " +
                "JOIN (" +
                "   SELECT DISTINCT course_id FROM attendance WHERE student_id=? " +
                "   UNION " +
                "   SELECT DISTINCT course_id FROM marks WHERE student_id=? " +
                ") sc ON a.course_id = sc.course_id"
            );
            psAssignments.setInt(1, studentId);
            psAssignments.setInt(2, studentId);
            ResultSet rsAssignments = psAssignments.executeQuery();
            if (rsAssignments.next()) {
                activeAssignments = rsAssignments.getInt("assignment_count");
            }
            rsAssignments.close();
            psAssignments.close();
        } catch (Exception ex) {
            activeAssignments = 0;
        }
    }

    con.close();
} catch (Exception e) {
    out.println("<p style='color:red;padding:10px;'>DB Error: " + e.getMessage() + "</p>");
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .attendance-ring-wrap {
            display: flex;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
        }

        .attendance-ring {
            width: 170px;
            height: 170px;
            border-radius: 50%;
            background:
                conic-gradient(#1f6feb 0% <%= attendancePercent %>%,
                               #e8eef6 <%= attendancePercent %>% 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow);
        }

        .attendance-ring-inner {
            width: 126px;
            height: 126px;
            border-radius: 50%;
            background: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        .attendance-ring-inner .value {
            font-size: 30px;
            font-weight: 800;
            color: var(--text);
            line-height: 1;
        }

        .attendance-ring-inner .label {
            margin-top: 6px;
            font-size: 12px;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }

        .student-summary-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 24px;
        }

        .student-summary-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 22px;
            min-height: 138px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .student-summary-card h4 {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
            font-weight: 600;
        }

        .student-summary-card .big {
            font-size: 34px;
            font-weight: 800;
            color: var(--text);
            letter-spacing: -0.7px;
            margin-top: 8px;
        }

        .student-summary-card .small {
            color: var(--muted);
            font-size: 13px;
            margin-top: 10px;
        }

        @media (max-width: 1200px) {
            .student-summary-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 640px) {
            .student-summary-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="app">

    <div class="sidebar">
        <div class="brand">SmartEduConnect</div>
        <div class="role-badge">Student Panel</div>

        <div class="nav-section">Overview</div>
        <a class="active" href="studentDashboard.jsp">Dashboard</a>

        <div class="nav-section">Academic</div>
        <a href="profile.jsp">My Profile</a>
        <a href="listCourses.jsp">Course Tracking</a>
        <a href="attendance.jsp">My Attendance</a>
        <a href="marks.jsp">My Marks</a>
        <a href="assignments.jsp">Assignments</a>

        <div class="nav-section">Session</div>
        <a href="login.html">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Student Dashboard</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div class="page-title">
                    <h1>Welcome to your academic portal</h1>
                    <p>
                        Track attendance, marks, assignments, and enrolled courses from one place through your student dashboard.
                        <% if(studentName != null && !studentName.isEmpty()) { %>
                        <br>
                        <span style="font-size:15px; color:#6b7280;">
                            <b><%= studentName %></b> | <%= rollNo %> | <%= department %> - Year <%= year %>
                        </span>
                        <% } %>
                    </p>
                </div>

                <div class="page-actions">
                    <a class="btn" href="attendance.jsp">View Attendance</a>
                    <a class="btn btn-secondary" href="marks.jsp">View Marks</a>
                </div>
            </div>

            <div class="student-summary-grid">
                <div class="student-summary-card">
                    <h4>Overall Attendance</h4>
                    <div class="big"><%= attendancePercent %>%</div>
                    <div class="small">Current academic attendance status</div>
                </div>

                <div class="student-summary-card">
                    <h4>Courses Enrolled</h4>
                    <div class="big"><%= totalCourses %></div>
                    <div class="small">Courses currently linked to your records</div>
                </div>

                <div class="student-summary-card">
                    <h4>Active Assignments</h4>
                    <div class="big"><%= activeAssignments %></div>
                    <div class="small">Assignments requiring attention</div>
                </div>

                <div class="student-summary-card">
                    <h4>Marks Updated</h4>
                    <div class="big"><%= marksUpdated %></div>
                    <div class="small">Recent academic evaluations available</div>
                </div>
            </div>

            <div class="dashboard-grid">
                <div class="stack">
                    <div class="card">
                        <h3 class="card-title">Attendance Overview</h3>
                        <p class="card-subtitle">Your current overall attendance status across all visible courses.</p>

                        <div class="attendance-ring-wrap">
                            <div class="attendance-ring">
                                <div class="attendance-ring-inner">
                                    <div class="value"><%= attendancePercent %>%</div>
                                    <div class="label">Attendance</div>
                                </div>
                            </div>

                            <div style="flex:1; min-width:260px;">
                                <div class="progress-wrap">
                                    <div class="progress-track">
                                        <div class="progress-fill" style="width:<%= attendancePercent %>%;"></div>
                                    </div>
                                    <div class="progress-meta">
                                        <b><%= attendancePercent %>%</b> overall attendance recorded across
                                        <b><%= totalClasses %></b> class record(s). Present count:
                                        <b><%= presentClasses %></b>
                                    </div>
                                </div>

                                <div class="form-actions">
                                    <a class="btn" href="attendance.jsp">View Detailed Attendance</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Recent Notifications</h3>
                        <p class="card-subtitle">Latest academic updates relevant to your role.</p>

                        <div class="list">
                            <div class="list-item">
                                <div class="list-item-title">Attendance records available</div>
                                <div class="list-item-meta">Your attendance summary is now linked to the database records.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Marks records updated</div>
                                <div class="list-item-meta">You currently have <b><%= marksUpdated %></b> marks entry/entries in the system.</div>
                            </div>

                            <div class="list-item">
                                <div class="list-item-title">Course records loaded</div>
                                <div class="list-item-meta">You are currently linked to <b><%= totalCourses %></b> course(s) through existing academic records.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="stack">
                    <div class="card">
                        <h3 class="card-title">Quick Access</h3>
                        <p class="card-subtitle">Open your most-used student modules directly.</p>

                        <div class="quick-links">
                            <a class="quick-link" href="profile.jsp">
                                <h4>My Profile</h4>
                                <p>View student identity and academic profile information.</p>
                            </a>

                            <a class="quick-link" href="listCourses.jsp">
                                <h4>My Courses</h4>
                                <p>Track enrolled subjects and related academic modules.</p>
                            </a>

                            <a class="quick-link" href="marks.jsp">
                                <h4>Marks</h4>
                                <p>View published academic results in a structured format.</p>
                            </a>

                            <a class="quick-link" href="assignments.jsp">
                                <h4>Assignments</h4>
                                <p>Review assignment notifications and pending academic tasks.</p>
                            </a>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="card-title">Student Access Scope</h3>
                        <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                        <p>Students can view attendance, marks, assignments, and course information. Attendance marking and marks entry are restricted to faculty modules only.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</body>
</html>