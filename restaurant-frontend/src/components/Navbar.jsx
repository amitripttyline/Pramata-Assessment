import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const Navbar = () => {
  const { user, logout, isAuthenticated, isAdmin } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  const isActive = (path) => location.pathname === path;

  return (
    <nav className="navbar navbar-expand-lg navbar-light bg-light shadow-sm border-bottom">
      <div className="container">
        {/* Logo */}
        <Link className="navbar-brand fw-bold text-primary" to="/">
          Restaurant Reservations
        </Link>

        {/* Mobile Toggle */}
        <button
          className="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarNav"
          aria-controls="navbarNav"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span className="navbar-toggler-icon"></span>
        </button>

        {/* Links */}
        <div className="collapse navbar-collapse" id="navbarNav">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0">
            <li className="nav-item">
              <Link
                className={`nav-link ${isActive('/') ? 'active' : ''}`}
                to="/"
              >
                Home
              </Link>
            </li>

            <li className="nav-item">
              <Link
                className={`nav-link ${isActive('/reviews') ? 'active' : ''}`}
                to="/reviews"
              >
                Reviews
              </Link>
            </li>

            {isAuthenticated && (
              <li className="nav-item">
                <Link
                  className={`nav-link ${isActive('/reservations') ? 'active' : ''}`}
                  to="/reservations"
                >
                  My Reservations
                </Link>
              </li>
            )}

            {isAdmin && (
              <li className="nav-item">
                <Link
                  className={`nav-link ${isActive('/admin') ? 'active' : ''}`}
                  to="/admin"
                >
                  Admin
                </Link>
              </li>
            )}
          </ul>

          {/* User Actions */}
          <div className="d-flex align-items-center">
            {isAuthenticated ? (
              <>
                <div className="d-flex align-items-center me-3">
                  <div className="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style={{ width: '32px', height: '32px' }}>
                    {user?.name?.charAt(0)?.toUpperCase()}
                  </div>
                  <div className="ms-2">
                    <div className="fw-bold">{user?.name}</div>
                    <small className="text-muted text-capitalize">{user?.role}</small>
                  </div>
                </div>
                <button className="btn btn-outline-danger btn-sm" onClick={handleLogout}>
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="btn btn-outline-primary me-2">
                  Login
                </Link>
                <Link to="/register" className="btn btn-primary">
                  Sign Up
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
