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

if (!"student".equalsIgnoreCase(role)) {
    response.sendRedirect("login.html");
    return;
}

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

int studentId = 0;
String name = "";
String rollNo = "";
String department = "";
int year = 0;

int totalClasses = 0;
int presentClasses = 0;
int attendancePercent = 0;
int marksCount = 0;
int totalCourses = 0;

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
        name = rsStudent.getString("name");
        department = rsStudent.getString("department");
        year = rsStudent.getInt("year");
    }

    rsStudent.close();
    psStudent.close();

    if (studentId > 0) {
        PreparedStatement psTotal = con.prepareStatement(
            "SELECT COUNT(*) AS total_classes FROM attendance WHERE student_id=?"
        );
        psTotal.setInt(1, studentId);
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) totalClasses = rsTotal.getInt("total_classes");
        rsTotal.close();
        psTotal.close();

        PreparedStatement psPresent = con.prepareStatement(
            "SELECT COUNT(*) AS present_classes FROM attendance WHERE student_id=? AND status='Present'"
        );
        psPresent.setInt(1, studentId);
        ResultSet rsPresent = psPresent.executeQuery();
        if (rsPresent.next()) presentClasses = rsPresent.getInt("present_classes");
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
        if (rsMarks.next()) marksCount = rsMarks.getInt("marks_count");
        rsMarks.close();
        psMarks.close();

        PreparedStatement psCourses = con.prepareStatement(
            "SELECT COUNT(DISTINCT course_id) AS total_courses " +
            "FROM (" +
            "   SELECT course_id FROM attendance WHERE student_id=? " +
            "   UNION " +
            "   SELECT course_id FROM marks WHERE student_id=? " +
            ") t"
        );
        psCourses.setInt(1, studentId);
        psCourses.setInt(2, studentId);
        ResultSet rsCourses = psCourses.executeQuery();
        if (rsCourses.next()) totalCourses = rsCourses.getInt("total_courses");
        rsCourses.close();
        psCourses.close();
    }

    con.close();

} catch (Exception e) {
    out.println("<p style='color:red; padding:10px;'>DB Error: " + e.getMessage() + "</p>");
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .profile-grid {
            display: grid;
            grid-template-columns: 340px 1fr;
            gap: 20px;
        }

        .profile-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 24px;
        }

        .profile-avatar {
            width: 96px;
            height: 96px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1f6feb, #4f8cff);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            font-weight: 800;
            margin-bottom: 18px;
        }

        .profile-name {
            font-size: 24px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .profile-role {
            color: var(--muted);
            font-size: 13px;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }

        .profile-meta {
            display: grid;
            gap: 14px;
        }

        .meta-item {
            padding: 14px 16px;
            border-radius: 14px;
            background: var(--surface-2);
            border: 1px solid var(--border);
        }

        .meta-label {
            font-size: 12px;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.7px;
            margin-bottom: 4px;
        }

        .meta-value {
            font-size: 16px;
            font-weight: 700;
            color: var(--text);
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .detail-box {
            padding: 18px;
            border-radius: 16px;
            border: 1px solid var(--border);
            background: white;
        }

        .detail-box h4 {
            margin: 0 0 8px 0;
            font-size: 13px;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.6px;
        }

        .detail-box p {
            margin: 0;
            font-size: 18px;
            font-weight: 700;
            color: var(--text);
        }

        .mini-stats {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 16px;
            margin-top: 18px;
        }

        .mini-stat {
            padding: 18px;
            border-radius: 16px;
            border: 1px solid var(--border);
            background: var(--surface-2);
        }

        .mini-stat .label {
            color: var(--muted);
            font-size: 13px;
            margin-bottom: 8px;
        }

        .mini-stat .value {
            font-size: 28px;
            font-weight: 800;
        }

        @media (max-width: 900px) {
            .profile-grid {
                grid-template-columns: 1fr;
            }

            .detail-grid,
            .mini-stats {
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
        <a href="studentDashboard.jsp">Dashboard</a>

        <div class="nav-section">Academic</div>
        <a class="active" href="profile.jsp">My Profile</a>
        <a href="attendance.jsp">My Attendance</a>
        <a href="marks.jsp">My Marks</a>
        <a href="listCourses.jsp">Course Tracking</a>
        <a href="assignments.jsp">Assignments</a>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>My Profile</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <div class="page-title">
                    <h1>Student Profile</h1>
                    <p>Your academic identity and student details available in SmartEduConnect.</p>
                </div>
            </div>

            <div class="profile-grid">
                <div class="profile-card">
                    <div class="profile-avatar">
                        <%= (name != null && name.length() > 0) ? name.substring(0,1).toUpperCase() : "S" %>
                    </div>

                    <div class="profile-name"><%= (name != null && !name.isEmpty()) ? name : "Student" %></div>
                    <div class="profile-role">Student Account</div>

                    <div class="profile-meta">
                        <div class="meta-item">
                            <div class="meta-label">Email</div>
                            <div class="meta-value"><%= email %></div>
                        </div>

                        <div class="meta-item">
                            <div class="meta-label">Roll Number</div>
                            <div class="meta-value"><%= rollNo %></div>
                        </div>

                        <div class="meta-item">
                            <div class="meta-label">Department</div>
                            <div class="meta-value"><%= department %></div>
                        </div>
                    </div>
                </div>

                <div class="profile-card">
                    <h3 class="card-title">Profile Details</h3>
                    <p class="card-subtitle">Verified student information and academic summary.</p>

                    <div class="detail-grid">
                        <div class="detail-box">
                            <h4>Student ID</h4>
                            <p><%= studentId %></p>
                        </div>

                        <div class="detail-box">
                            <h4>Academic Year</h4>
                            <p><%= year %></p>
                        </div>

                        <div class="detail-box">
                            <h4>Full Name</h4>
                            <p><%= name %></p>
                        </div>

                        <div class="detail-box">
                            <h4>Institutional Email</h4>
                            <p><%= email %></p>
                        </div>
                    </div>

                    <div class="mini-stats">
                        <div class="mini-stat">
                            <div class="label">Attendance</div>
                            <div class="value"><%= attendancePercent %>%</div>
                        </div>

                        <div class="mini-stat">
                            <div class="label">Marks Records</div>
                            <div class="value"><%= marksCount %></div>
                        </div>

                        <div class="mini-stat">
                            <div class="label">Courses</div>
                            <div class="value"><%= totalCourses %></div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a class="btn" href="attendance.jsp">View Attendance</a>
                        <a class="btn btn-secondary" href="marks.jsp">View Marks</a>
                        <a class="btn btn-secondary" href="listCourses.jsp">View Courses</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</body>
</html>