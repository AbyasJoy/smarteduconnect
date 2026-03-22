<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Dashboard - SmartEduConnect</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="app">
  <div class="sidebar">
    <div class="brand">SmartEduConnect</div>

    <a href="dashboard.jsp">Dashboard</a>
    <a href="listStudents.jsp">Students</a>
    <a href="listFaculty.jsp">Faculty</a>
    <a href="listCourses.jsp">Courses</a>
    <a href="attendance.jsp">Attendance</a>
    <a href="marks.jsp">Marks</a>
    <a href="profile.jsp">Profile</a>
    <a href="logout.jsp">Logout</a>
  </div>

  <div class="main">
    <div class="topbar">
      <h2>Dashboard</h2>
      <div class="tag">Academic Management System</div>
    </div>

    <div class="page-content">
      <div class="card">
        <h1 class="page-title">Welcome to SmartEduConnect</h1>
        <p class="page-subtitle">
          Manage students, faculty, courses, attendance, marks, and profile information through a unified portal.
        </p>
      </div>

      <div class="grid-stats">
        <div class="stat-box">
          <h4>Student Module</h4>
          <p>CRUD</p>
        </div>
        <div class="stat-box">
          <h4>Faculty Module</h4>
          <p>Manage</p>
        </div>
        <div class="stat-box">
          <h4>Course Module</h4>
          <p>Track</p>
        </div>
        <div class="stat-box">
          <h4>Attendance & Marks</h4>
          <p>Live</p>
        </div>
      </div>

      <div class="card">
        <h2 class="page-title" style="font-size:24px;">Quick Access</h2>
        <p class="page-subtitle">Use these shortcuts to navigate across major modules.</p>

        <div class="quick-links">
          <a href="addStudent.jsp">Add Student</a>
          <a href="listStudents.jsp">View Students</a>
          <a href="addFaculty.jsp">Add Faculty</a>
          <a href="listFaculty.jsp">View Faculty</a>
          <a href="addCourse.jsp">Add Course</a>
          <a href="listCourses.jsp">View Courses</a>
          <a href="attendance.jsp">Attendance</a>
          <a href="marks.jsp">Marks</a>
          <a href="assignCourseFaculty.jsp">Assign Courses</a>
          <a href="profile.jsp">Profile</a>
        </div>
      </div>
    </div>
  </div>
</div>

</body>
</html>