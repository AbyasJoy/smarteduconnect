import React from 'react';
import 'bootstrap/dist/css/bootstrap.min.css'; // Import Bootstrap for styling
import Dashboard from './Dashboard';

function App() {
  return (
    <div className="App">
      <header className="bg-primary text-white text-center py-4">
        <h1>SmartEduConnect Dashboard</h1>
        <p>Manage Students and Faculty</p>
      </header>
      <Dashboard />
    </div>
  );
}

export default App;