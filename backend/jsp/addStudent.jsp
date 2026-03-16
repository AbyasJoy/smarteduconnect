<%@ page import="java.sql.*" %>
<%
String role = (String) session.getAttribute("role");
String emailSession = (String) session.getAttribute("email");

if (role == null || emailSession == null) {
    response.sendRedirect("login.html");
    return;
}

if (!"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("dashboard.jsp");
    return;
}

String successMessage = "";
String errorMessage = "";

String URL = "jdbc:mysql://localhost:3306/smarteduconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String USER = "root";
String PASS = "Joy@1234";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String roll = request.getParameter("roll_no");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String dept = request.getParameter("department");
    String yearStr = request.getParameter("year");

    try {
        int year = Integer.parseInt(yearStr);

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(URL, USER, PASS);

        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO student (roll_no, name, email, department, year) VALUES (?,?,?,?,?)"
        );
        ps.setString(1, roll);
        ps.setString(2, name);
        ps.setString(3, email);
        ps.setString(4, dept);
        ps.setInt(5, year);

        ps.executeUpdate();
        con.close();

        successMessage = "Student added successfully.";
    } catch (SQLIntegrityConstraintViolationException e) {
        errorMessage = "Student already exists with the same roll number or email.";
    } catch (NumberFormatException e) {
        errorMessage = "Year must be a valid number.";
    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add Student - SmartEduConnect</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="app">

    <%@ include file="layout-sidebar.jspf" %>

    <div class="main">
        <%@ include file="layout-header.jspf" %>

        <div class="page-content">
            <div class="page-title">
                <h1>Add Student</h1>
                <p>Create a new student record in the SmartEduConnect academic portal.</p>
            </div>

            <div class="card">
                <% if (!successMessage.isEmpty()) { %>
                    <div class="alert-success"><%= successMessage %></div>
                <% } %>

                <% if (!errorMessage.isEmpty()) { %>
                    <div class="alert-error"><%= errorMessage %></div>
                <% } %>

                <form method="post">
                    <div class="form-grid">
                        <div>
                            <label for="roll_no">Roll Number</label>
                            <input type="text" id="roll_no" name="roll_no" required>
                        </div>

                        <div>
                            <label for="name">Full Name</label>
                            <input type="text" id="name" name="name" required>
                        </div>

                        <div>
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" required>
                        </div>

                        <div>
                            <label for="department">Department</label>
                            <input type="text" id="department" name="department" required>
                        </div>

                        <div>
                            <label for="year">Year</label>
                            <input type="number" id="year" name="year" min="1" max="4" required>
                        </div>
                    </div>

                    <div class="actions">
                        <button type="submit">Add Student</button>
                        <a class="btn btn-outline" href="listStudents.jsp">View Students</a>
                        <a class="btn btn-outline" href="dashboard.jsp">Back to Dashboard</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>
</body>
</html>