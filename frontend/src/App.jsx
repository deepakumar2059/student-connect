import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import Home from './pages/Home.jsx'
import Discover from './pages/Discover.jsx'
import CreateProfile from './pages/CreateProfile.jsx'
import Register from './pages/Register.jsx'
import Login from './pages/Login.jsx'
import { useAuth } from './contexts/AuthContext.jsx'
import './App.css'

function App() {
  const { user, signOut } = useAuth()

  return (
    <BrowserRouter>
      <div className="app-shell">
        <header className="app-header">
          <Link to="/" className="brand">
            Student Connect
          </Link>
          <nav className="app-nav">
            <Link to="/discover">Discover</Link>
            <Link to="/create-profile">Create Profile</Link>
            {!user ? (
              <>
                <Link to="/register">Register</Link>
                <Link to="/login">Login</Link>
              </>
            ) : (
              <button type="button" className="button button-secondary" onClick={signOut}>
                Logout
              </button>
            )}
          </nav>
        </header>

        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/discover" element={<Discover />} />
          <Route path="/create-profile" element={<CreateProfile />} />
          <Route path="/register" element={<Register />} />
          <Route path="/login" element={<Login />} />
        </Routes>

        <footer className="app-footer">
          <p>Student Connect — helping students form study groups, launch clubs, and expand campus networks.</p>
        </footer>
      </div>
    </BrowserRouter>
  )
}

export default App
