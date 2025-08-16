import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';

const Login = () => {
  const { login, error, setError } = useAuth();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    const result = await login(formData.email, formData.password);
    
    if (result.success) {
      navigate('/');
    }
    
    setLoading(false);
  };

  return (
  <div className="container py-5 d-flex justify-content-center align-items-center" style={{ minHeight: '100vh' }}>
    <div className="card shadow-lg p-4 w-100" style={{ maxWidth: '400px' }}>
      <div className="text-center mb-4">
        <h2 className="h3 fw-bold text-primary">Welcome Back</h2>
        <p className="text-muted mt-2">Sign in to your account</p>
        </div>

        {error && (
          <div className="alert alert-danger mb-4" role="alert">
            <small>{error}</small>
          </div>
        )}

  <form onSubmit={handleSubmit}>
          <div>
            <label htmlFor="email" className="form-label">
              Email Address
            </label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
              className="form-control"
              placeholder="Enter your email"
            />
          </div>

          <div>
            <label htmlFor="password" className="form-label">
              Password
            </label>
            <div className="position-relative">
              <input
                type={showPassword ? 'text' : 'password'}
                id="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                required
                className="form-control pr-5"
                placeholder="Enter your password"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="btn btn-link position-absolute end-0 top-50 translate-middle-y p-0"
                style={{ right: '10px' }}
              >
                {showPassword ? (
                  <EyeSlashIcon className="h-5 w-5" />
                ) : (
                  <EyeIcon className="h-5 w-5" />
                )}
              </button>
            </div>
          </div>

            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary w-100"
            >
              {loading ? (
                <span>
                  <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                  Signing In...
                </span>
              ) : (
                'Sign In'
              )}
            </button>
        </form>

        <div className="mt-4 text-center">
          <p className="text-muted">
            Don't have an account?{' '}
            <Link to="/register" className="fw-medium text-primary text-decoration-underline">
              Sign up here
            </Link>
          </p>
        </div>

        {/* Demo credentials */}
        <div className="mt-4 p-3 bg-light rounded">
          <h4 className="fs-6 fw-medium text-dark mb-2">Demo Accounts:</h4>
          <div className="small text-muted">
            <p><strong>Customer:</strong> customer1@example.com / password123</p>
            <p><strong>Admin:</strong> admin@restaurant.com / password123</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
