
import React, { useEffect, useState } from 'react';
import { reservationsAPI } from '../services/api';

const Reservations = () => {
  const [reservations, setReservations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchReservations = async () => {
      try {
        setLoading(true);
        const response = await reservationsAPI.getAll();
        setReservations(response.data.reservations || []);
        setError('');
      } catch (err) {
        setError('Failed to fetch reservations');
      } finally {
        setLoading(false);
      }
    };
    fetchReservations();
  }, []);

  return (
    <div className="container py-4">
      <div className="row justify-content-center mb-4">
        <div className="col-lg-8 text-center">
          <h1 className="display-5 fw-bold text-primary mb-3">My Reservations</h1>
          <p className="lead text-secondary">Manage your restaurant reservations</p>
        </div>
      </div>
      {loading ? (
        <div className="text-center py-5">
          <div className="spinner-border text-primary mb-3" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
          <p className="text-secondary">Loading your reservations...</p>
        </div>
      ) : error ? (
        <div className="alert alert-danger text-center py-5">{error}</div>
      ) : reservations.length === 0 ? (
        <div className="alert alert-info text-center py-5">You have no reservations yet.</div>
      ) : (
        <div className="table-responsive">
          <table className="table table-bordered table-hover align-middle">
            <thead className="table-light">
              <tr>
                <th>Date</th>
                <th>Time</th>
                <th>Table</th>
                <th>Party Size</th>
                <th>Status</th>
                <th>Special Requests</th>
              </tr>
            </thead>
            <tbody>
              {reservations.map((r) => (
                <tr key={r.id}>
                  <td>{new Date(r.reservation_date).toLocaleDateString()}</td>
                  <td>{r.time_slot?.time_range || '-'}</td>
                  <td>{r.table?.name || '-'}</td>
                  <td>{r.party_size}</td>
                  <td><span className={`badge bg-${r.status === 'confirmed' ? 'success' : r.status === 'pending' ? 'warning' : 'secondary'}`}>{r.status}</span></td>
                  <td>{r.special_requests || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default Reservations;
