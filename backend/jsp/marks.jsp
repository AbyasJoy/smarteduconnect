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
int studentId = 0;
String studentName = "";
String rollNo = "";
int marksCount = 0;
double averageScore = 0.0;
int highestScore = 0;

/* ---------- FACULTY VARIABLES ---------- */
int facultyId = 0;
String facultyName = "";
int totalMarksRecords = 0;
int totalStudentsCovered = 0;

/* ---------- FACULTY SAVE MARKS ---------- */
if ("faculty".equalsIgnoreCase(role) && "POST".equalsIgnoreCase(request.getMethod())) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        int sid = Integer.parseInt(request.getParameter("student_id"));
        int cid = Integer.parseInt(request.getParameter("course_id"));
        String examType = request.getParameter("exam_type");
        int score = Integer.parseInt(request.getParameter("score"));

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
        psCheck.setInt(2, cid);
        ResultSet rsCheck = psCheck.executeQuery();

        int allowed = 0;
        if (rsCheck.next()) {
            allowed = rsCheck.getInt(1);
        }
        rsCheck.close();
        psCheck.close();

        if (allowed == 0) {
            throw new Exception("You can only manage marks for your assigned courses.");
        }

        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO marks (student_id, course_id, exam_type, score) VALUES (?,?,?,?)"
        );
        ps.setInt(1, sid);
        ps.setInt(2, cid);
        ps.setString(3, examType);
        ps.setInt(4, score);

        ps.executeUpdate();
        ps.close();
        con.close();

        successMessage = "Marks saved successfully.";

    } catch (NumberFormatException nfe) {
        errorMessage = "Student ID, Course ID and Score must be numeric values.";
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

        if (studentId > 0) {
            PreparedStatement psCount = con.prepareStatement(
                "SELECT COUNT(*) AS marks_count FROM marks WHERE student_id=?"
            );
            psCount.setInt(1, studentId);
            ResultSet rsCount = psCount.executeQuery();
            if (rsCount.next()) {
                marksCount = rsCount.getInt("marks_count");
            }
            rsCount.close();
            psCount.close();

            PreparedStatement psAvg = con.prepareStatement(
                "SELECT IFNULL(AVG(score),0) AS avg_score FROM marks WHERE student_id=?"
            );
            psAvg.setInt(1, studentId);
            ResultSet rsAvg = psAvg.executeQuery();
            if (rsAvg.next()) {
                averageScore = rsAvg.getDouble("avg_score");
            }
            rsAvg.close();
            psAvg.close();

            PreparedStatement psHigh = con.prepareStatement(
                "SELECT IFNULL(MAX(score),0) AS high_score FROM marks WHERE student_id=?"
            );
            psHigh.setInt(1, studentId);
            ResultSet rsHigh = psHigh.executeQuery();
            if (rsHigh.next()) {
                highestScore = rsHigh.getInt("high_score");
            }
            rsHigh.close();
            psHigh.close();
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
                "FROM marks m " +
                "JOIN faculty_course fc ON m.course_id = fc.course_id " +
                "WHERE fc.faculty_id = ?"
            );
            psRecords.setInt(1, facultyId);
            ResultSet rsRecords = psRecords.executeQuery();
            if (rsRecords.next()) totalMarksRecords = rsRecords.getInt(1);
            rsRecords.close();
            psRecords.close();

            PreparedStatement psStudents = con.prepareStatement(
                "SELECT COUNT(DISTINCT m.student_id) " +
                "FROM marks m " +
                "JOIN faculty_course fc ON m.course_id = fc.course_id " +
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
<title>Marks - SmartEduConnect</title>
<link rel="stylesheet" href="style.css">
<style>
    .marks-summary-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 18px;
        margin-bottom: 24px;
    }

    .marks-summary-card {
        background: white;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        box-shadow: var(--shadow);
        padding: 22px;
        min-height: 130px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

    .marks-summary-card h4 {
        margin: 0;
        color: var(--muted);
        font-size: 14px;
        font-weight: 600;
    }

    .marks-summary-card .big {
        font-size: 34px;
        font-weight: 800;
        color: var(--text);
        margin-top: 8px;
    }

    .marks-summary-card .small {
        color: var(--muted);
        font-size: 13px;
        margin-top: 10px;
    }

    @media (max-width: 900px) {
        .marks-summary-grid {
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
        <% } %>

        <div class="nav-section">Academic</div>
        <% if ("student".equalsIgnoreCase(role)) { %>
            <a href="profile.jsp">My Profile</a>
            <a href="attendance.jsp">My Attendance</a>
            <a class="active" href="marks.jsp">My Marks</a>
            <a href="listCourses.jsp">Course Tracking</a>
            <a href="assignments.jsp">Assignments</a>
        <% } else if ("faculty".equalsIgnoreCase(role)) { %>
            <a href="listCourses.jsp">Assigned Courses</a>
            <a href="attendance.jsp">Manage Attendance</a>
            <a class="active" href="marks.jsp">Upload Marks</a>
            <a href="assignments.jsp">Assignments</a>
        <% } %>

        <div class="nav-section">Session</div>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2>Marks</h2>
            <div class="user-meta"><%= email %></div>
        </div>

        <div class="page-content">

            <% if (!successMessage.isEmpty()) { %>
                <div class="alert-success"><%= successMessage %></div>
            <% } %>

            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert-error"><%= errorMessage %></div>
            <% } %>

            <!-- ================= STUDENT VIEW ================= -->
            <% if ("student".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>My Academic Results</h1>
                    <p>
                        View your marks and assessment records.
                        <% if(studentName != null && !studentName.isEmpty()) { %>
                        <br>
                        <span style="font-size:15px; color:#6b7280;">
                            <b><%= studentName %></b> | <%= rollNo %>
                        </span>
                        <% } %>
                    </p>
                </div>

                <div class="page-actions">
                    <a class="btn" href="studentDashboard.jsp">Back to Dashboard</a>
                </div>
            </div>

            <div class="marks-summary-grid">
                <div class="marks-summary-card">
                    <h4>Marks Records</h4>
                    <div class="big"><%= marksCount %></div>
                    <div class="small">Total assessment entries available</div>
                </div>

                <div class="marks-summary-card">
                    <h4>Average Score</h4>
                    <div class="big"><%= String.format("%.1f", averageScore) %></div>
                    <div class="small">Average across all recorded marks</div>
                </div>

                <div class="marks-summary-card">
                    <h4>Highest Score</h4>
                    <div class="big"><%= highestScore %></div>
                    <div class="small">Best score achieved so far</div>
                </div>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Marks Records</h3>
                    <p>Your published course-wise marks are displayed below.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Course Code</th>
                            <th>Course Name</th>
                            <th>Exam Type</th>
                            <th>Score</th>
                            <th>Result</th>
                        </tr>

<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(URL, USER, PASS);

    PreparedStatement ps = con.prepareStatement(
        "SELECT m.marks_id, c.course_code, c.course_name, m.exam_type, m.score " +
        "FROM marks m " +
        "JOIN course c ON m.course_id = c.course_id " +
        "WHERE m.student_id = ? " +
        "ORDER BY m.marks_id DESC"
    );
    ps.setInt(1, studentId);

    ResultSet rs = ps.executeQuery();

    while (rs.next()) {
        int score = rs.getInt("score");
%>
                        <tr>
                            <td><%= rs.getInt("marks_id") %></td>
                            <td><%= rs.getString("course_code") %></td>
                            <td><%= rs.getString("course_name") %></td>
                            <td><%= rs.getString("exam_type") %></td>
                            <td><b><%= score %></b></td>
                            <td>
                                <span class="status-badge <%= score >= 40 ? "status-good" : "status-bad" %>">
                                    <%= score >= 40 ? "Pass" : "Needs Improvement" %>
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
<%
}
%>
                    </table>
                </div>
            </div>

            <div class="card" style="margin-top:24px;">
                <h3 class="card-title">Student Access Scope</h3>
                <p class="card-subtitle">Role permissions inside SmartEduConnect.</p>
                <p>Students can only view published marks. Marks entry, updates, and academic evaluation management are restricted to faculty and admin modules.</p>
            </div>

            <% } %>

            <!-- ================= FACULTY VIEW ================= -->
            <% if ("faculty".equalsIgnoreCase(role)) { %>

            <div class="page-header">
                <div class="page-title">
                    <h1>Marks Management</h1>
                    <p>
                        Upload and monitor marks only for your assigned courses.
                        <% if(facultyName != null && !facultyName.isEmpty()) { %>
                        <br><span style="font-size:15px; color:#6b7280;"><b><%= facultyName %></b></span>
                        <% } %>
                    </p>
                </div>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label">Marks Records</div>
                    <div class="kpi-value"><%= totalMarksRecords %></div>
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
                    <div class="kpi-subtext">Marks control enabled</div>
                </div>
            </div>

            <div class="card form-shell">
                <h3 class="card-title">Upload Marks</h3>
                <p class="card-subtitle">Marks can only be saved for your assigned courses.</p>

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
                            <label>Exam Type</label>
                            <input type="text" name="exam_type" placeholder="Mid / End / Sem" required>
                        </div>

                        <div class="field">
                            <label>Score</label>
                            <input type="number" name="score" min="0" max="100" required>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn" type="submit">Save Marks</button>
                    </div>
                </form>
            </div>

            <div class="table-shell">
                <div class="table-header">
                    <h3>Marks Records for Your Courses</h3>
                    <p>You can view marks only for the courses assigned to you.</p>
                </div>

                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Student Name</th>
                            <th>Roll No</th>
                            <th>Course</th>
                            <th>Exam Type</th>
                            <th>Score</th>
                        </tr>

                        <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection con = DriverManager.getConnection(URL, USER, PASS);

                            PreparedStatement ps = con.prepareStatement(
                                "SELECT m.marks_id, s.name, s.roll_no, c.course_code, m.exam_type, m.score " +
                                "FROM marks m " +
                                "JOIN student s ON m.student_id = s.student_id " +
                                "JOIN course c ON m.course_id = c.course_id " +
                                "JOIN faculty_course fc ON m.course_id = fc.course_id " +
                                "JOIN faculty f ON fc.faculty_id = f.faculty_id " +
                                "WHERE f.email = ? " +
                                "ORDER BY m.marks_id DESC"
                            );
                            ps.setString(1, email);

                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getInt("marks_id") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td><%= rs.getString("roll_no") %></td>
                            <td><%= rs.getString("course_code") %></td>
                            <td><%= rs.getString("exam_type") %></td>
                            <td><b><%= rs.getInt("score") %></b></td>
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
                <p>Faculty can upload and monitor marks only for their assigned courses. Student marks remain view-only on the student side.</p>
            </div>

            <% } %>

        </div>
    </div>

</div>

</body>
</html>