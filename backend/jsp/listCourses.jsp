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

String facultyName = "";
int assignedCourseCount = 0;

if ("faculty".equalsIgnoreCase(role)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement psFaculty = con.prepareStatement(
            "SELECT faculty_id, faculty_name FROM faculty WHERE email=?"
        );
        psFaculty.setString(1, email);
        ResultSet rsFaculty = psFaculty.executeQuery();

        int facultyId = 0;
        if (rsFaculty.next()) {
            facultyId = rsFaculty.getInt("faculty_id");
            facultyName = rsFaculty.getString("faculty_name");
        }
        rsFaculty.close();
        psFaculty.close();

        if (facultyId > 0) {
            PreparedStatement psCount = con.prepareStatement(
                "SELECT COUNT(*) FROM faculty_course WHERE faculty_id=?"
            );
            psCount.setInt(1, facultyId);
            ResultSet rsCount = psCount.executeQuery();
            if (rsCount.next()) {
                assignedCourseCount = rsCount.getInt(1);
            }
            rsCount.close();
            psCount.close();
        }

        con.close();
    } catch (Exception e) {
        out.println("<p style='color:red; padding:10px;'>Error: " + e.getMessage() + "</p>");
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Courses - SmartEduConnect</title>
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
            <a href="attendance.jsp">My Attendance</a>
            <a href="marks.jsp">My Marks</a>
            <a class="active" href="listCourses.jsp">Course Tracking</a>
            <a href="assignments.jsp">Assignments</a>
        <% } else if ("faculty".equalsIgnoreCase(role)) { %>
            <a class="active" href="listCourses.jsp">Assigned Courses</a>
            <a href="attendance.jsp">Manage Attendance</a>
            <a href="marks.jsp">Upload Marks</a>
            <a href="assignments.jsp">Assignments</a>
        <% } %>

        <div class="nav-section">Session</div>
        <a href="login.html">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Courses</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">

            <% if ("student".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Course Catalog</h1>
                    <p>Courses currently available in the SmartEduConnect academic system.</p>
                </div>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Courses</h3>
                    <p>All courses registered in the academic portal.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Course Code</th>
                            <th>Course Name</th>
                        </tr>

<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery(
        "SELECT course_id, course_code, course_name FROM course ORDER BY course_id DESC"
    );

    while (rs.next()) {
%>
                        <tr>
                            <td><%= rs.getInt("course_id") %></td>
                            <td><b><%= rs.getString("course_code") %></b></td>
                            <td><%= rs.getString("course_name") %></td>
                        </tr>
<%
    }

    rs.close();
    st.close();
    con.close();

} catch (Exception e) {
%>
                        <tr>
                            <td colspan="3" style="color:red;">Error: <%= e.getMessage() %></td>
                        </tr>
<%
}
%>
                    </table>
                </div>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Student Access Scope</h3>
                <p class="card-subtitle">
                    Students can view courses available in the academic portal. Course creation, modification, and deletion are restricted to admin workflows.
                </p>
            </div>

            <% } %>

            <% if ("faculty".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Assigned Courses</h1>
                    <p>
                        Courses mapped to your faculty account.
                        <% if(facultyName != null && !facultyName.isEmpty()) { %>
                        <br><span style="font-size:15px; color:#6b7280;"><b><%= facultyName %></b></span>
                        <% } %>
                    </p>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Assigned Courses</div>
                    <div class="kpi-value"><%= assignedCourseCount %></div>
                    <div class="kpi-subtext">Courses currently mapped to you</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Role</div>
                    <div class="kpi-value">Faculty</div>
                    <div class="kpi-subtext">Course-level access only</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Module</div>
                    <div class="kpi-value">Live</div>
                    <div class="kpi-subtext">Course visibility enabled</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Scope</div>
                    <div class="kpi-value">Assigned</div>
                    <div class="kpi-subtext">Restricted to mapped courses</div>
                </div>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Your Courses</h3>
                    <p>Only the courses assigned to your faculty account are displayed below.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Course Code</th>
                            <th>Course Name</th>
                        </tr>

<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement ps = con.prepareStatement(
        "SELECT c.course_id, c.course_code, c.course_name " +
        "FROM faculty_course fc " +
        "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
        "JOIN course c ON fc.course_id = c.course_id " +
        "WHERE f.email = ? " +
        "ORDER BY c.course_id DESC"
    );
    ps.setString(1, email);

    ResultSet rs = ps.executeQuery();

    while (rs.next()) {
%>
                        <tr>
                            <td><%= rs.getInt("course_id") %></td>
                            <td><b><%= rs.getString("course_code") %></b></td>
                            <td><%= rs.getString("course_name") %></td>
                        </tr>
<%
    }

    rs.close();
    ps.close();
    con.close();

} catch (Exception e) {
%>
                        <tr>
                            <td colspan="3" style="color:red;">Error: <%= e.getMessage() %></td>
                        </tr>
<%
}
%>
                    </table>
                </div>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Faculty Access Scope</h3>
                <p class="card-subtitle">
                    Faculty can view only their assigned courses. Course creation, modification, and broader allocation remain restricted to admin workflows.
                </p>
            </div>

            <% } %>

        </div>
    </div>

</div>
</body>
</html>