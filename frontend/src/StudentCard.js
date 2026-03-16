import React from 'react';

function StudentCard({ name, id, courses }) { // Props: name, id, courses
  return (
    <div className="card h-100 shadow-sm">
      <div className="card-body">
        <h5 className="card-title">{name}</h5>
        <p className="card-text"><strong>ID:</strong> {id}</p>
        <p className="card-text"><strong>Courses:</strong> {courses.join(', ')}</p>
      </div>
    </div>
  );
}

export default StudentCard;