import React from 'react';

function FacultyCard({ name, department, courses }) { // Props: name, department, courses
  return (
    <div className="card h-100 shadow-sm">
      <div className="card-body">
        <h5 className="card-title">{name}</h5>
        <p className="card-text"><strong>Department:</strong> {department}</p>
        <p className="card-text"><strong>Courses Taught:</strong> {courses.join(', ')}</p>
      </div>
    </div>
  );
}

export default FacultyCard;