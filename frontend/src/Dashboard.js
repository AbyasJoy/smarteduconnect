import React, { useState, useEffect } from 'react';
import StudentCard from './StudentCard';
import FacultyCard from './FacultyCard';

function Dashboard() {
  // State for students and faculty lists
  const [students, setStudents] = useState([]);
  const [faculty, setFaculty] = useState([]);
  const [loading, setLoading] = useState(true);

  // useEffect to simulate data fetching on mount
  useEffect(() => {
    // Mock data fetching (simulate API call)
    setTimeout(() => {
      setStudents([
        { id: 1, name: 'Alice Johnson', courses: ['Math 101', 'Physics 201'] },
        { id: 2, name: 'Bob Smith', courses: ['Chemistry 101', 'Biology 201'] },
      ]);
      setFaculty([
        { id: 1, name: 'Dr. Emily Davis', department: 'Computer Science', courses: ['CS 101', 'AI 301'] },
        { id: 2, name: 'Prof. John Lee', department: 'Mathematics', courses: ['Calculus 201', 'Statistics 301'] },
      ]);
      setLoading(false); // Stop loading after data is "fetched"
    }, 2000); // Simulate 2-second delay
  }, []); // Empty dependency array: runs once on mount

  if (loading) {
    return <div className="container mt-4 text-center"><p>Loading dashboard...</p></div>;
  }

  return (
    <div className="container mt-4">
      <h2>Students</h2>
      <div className="row">
        {students.map(student => (
          <div key={student.id} className="col-md-6 mb-4">
            <StudentCard {...student} /> {/* Spread props for reusability */}
          </div>
        ))}
      </div>
      
      <h2>Faculty</h2>
      <div className="row">
        {faculty.map(facultyMember => (
          <div key={facultyMember.id} className="col-md-6 mb-4">
            <FacultyCard {...facultyMember} /> {/* Spread props for reusability */}
          </div>
        ))}
      </div>
    </div>
  );
}

export default Dashboard;