import React, { useState, useEffect } from 'react';
import { useRef } from 'react';
import { timeSlotsAPI, reservationsAPI } from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import { 
  CalendarDaysIcon, 
  ClockIcon, 
  MapPinIcon, 
  UsersIcon,
  CurrencyDollarIcon,
  SparklesIcon 
} from '@heroicons/react/24/outline';

const Home = () => {
  const debounceTimeout = useRef(null);
  const { isAuthenticated } = useAuth();
  const [timeSlots, setTimeSlots] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filters, setFilters] = useState({
    date: new Date().toISOString().split('T')[0],
    party_size: '',
    area: '',
  });
  const [selectedSlot, setSelectedSlot] = useState(null);
  const [reservationForm, setReservationForm] = useState({
    party_size: 2,
    special_requests: '',
  });
  const [reservationLoading, setReservationLoading] = useState(false);

  useEffect(() => {
    // Debounce API calls for filter changes
    if (debounceTimeout.current) clearTimeout(debounceTimeout.current);
    debounceTimeout.current = setTimeout(() => {
      fetchTimeSlots();
    }, 400); // 400ms debounce
    return () => {
      if (debounceTimeout.current) clearTimeout(debounceTimeout.current);
    };
  }, [filters]);

  const fetchTimeSlots = async () => {
    try {
      setLoading(true);
      const response = await timeSlotsAPI.getAvailable(filters);
      setTimeSlots(response.data.time_slots);
      setError('');
    } catch (error) {
      setError('Failed to fetch available time slots');
      console.error('Error fetching time slots:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const handleReservation = async (timeSlot) => {
    if (!isAuthenticated) {
      alert('Please login to make a reservation');
      return;
    }
    setSelectedSlot(timeSlot);
    setReservationForm({
      party_size: Math.min(2, timeSlot.table.capacity),
      special_requests: '',
    });
  };

  const submitReservation = async (e) => {
    e.preventDefault();
    if (!selectedSlot) return;

    try {
      setReservationLoading(true);
      await reservationsAPI.create({
        time_slot_id: selectedSlot.id,
        party_size: reservationForm.party_size,
        special_requests: reservationForm.special_requests,
      });
      alert('Reservation created successfully!');
      setSelectedSlot(null);
      fetchTimeSlots(); // Refresh the available slots
    } catch (error) {
      const errorMessage = error.response?.data?.error || 'Failed to create reservation';
      alert(errorMessage);
    } finally {
      setReservationLoading(false);
    }
  };

  const getAreaIcon = (area) => {
    switch (area) {
      case 'outdoor': return '🌿';
      case 'private_dining': return '🏛️';
      default: return '🏠';
    }
  };

  const formatArea = (area) => {
    return area.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
  };

  return (
    <div className="container py-4">
      <div className="row justify-content-center mb-4">
        <div className="col-lg-8 text-center">
          <h1 className="display-4 fw-bold text-primary mb-3">Restaurant Reservations</h1>
          <p className="lead text-secondary">Discover and book your perfect dining experience</p>
        </div>
      </div>

      {/* Filters */}
      <div className="card shadow-sm mb-4">
        <div className="card-body">
          <h3 className="h5 fw-semibold text-dark mb-3">Find Your Table</h3>
          <div className="row g-3">
            <div className="col-md-4">
              <label className="form-label">Date</label>
              <input
                type="date"
                value={filters.date}
                min={new Date().toISOString().split('T')[0]}
                onChange={(e) => handleFilterChange('date', e.target.value)}
                className="form-control"
              />
            </div>
            <div className="col-md-4">
              <label className="form-label">Party Size</label>
              <select
                value={filters.party_size}
                onChange={(e) => handleFilterChange('party_size', e.target.value)}
                className="form-select"
              >
                <option value="">Any Size</option>
                <option value="2">2 People</option>
                <option value="4">4 People</option>
                <option value="6">6 People</option>
                <option value="8">8+ People</option>
              </select>
            </div>
            <div className="col-md-4">
              <label className="form-label">Area</label>
              <select
                value={filters.area}
                onChange={(e) => handleFilterChange('area', e.target.value)}
                className="form-select"
              >
                <option value="">All Areas</option>
                <option value="indoor">Indoor</option>
                <option value="outdoor">Outdoor</option>
                <option value="private_dining">Private Dining</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Time Slots Grid */}
      {loading ? (
        <div className="text-center py-5">
          <div className="spinner-border text-primary mb-3" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
          <p className="text-secondary">Loading available time slots...</p>
        </div>
      ) : error ? (
        <div className="alert alert-danger text-center py-5">{error}</div>
      ) : timeSlots.length === 0 ? (
        <div className="alert alert-info text-center py-5">No available time slots for the selected filters.</div>
      ) : (
        <div className="row g-4">
          {timeSlots.map((slot) => (
            <div key={slot.id} className="col-md-6 col-lg-4">
              <div className="card h-100 shadow-sm">
                <div className="card-body">
                  <div className="d-flex justify-content-between align-items-center mb-2">
                    <h5 className="card-title fw-bold text-dark mb-0">{slot.table.name}</h5>
                    <span className="fs-3">{getAreaIcon(slot.table.area)}</span>
                  </div>
                  <ul className="list-unstyled mb-3">
                    <li className="mb-1"><ClockIcon className="me-2" style={{height: '1em'}} />{slot.time_range}</li>
                    <li className="mb-1"><CalendarDaysIcon className="me-2" style={{height: '1em'}} />{new Date(slot.date).toLocaleDateString()}</li>
                    <li className="mb-1"><UsersIcon className="me-2" style={{height: '1em'}} />Seats {slot.table.capacity} people</li>
                    <li className="mb-1"><MapPinIcon className="me-2" style={{height: '1em'}} />{formatArea(slot.table.area)}</li>
                    {slot.table.price_per_person && (
                      <li className="mb-1"><CurrencyDollarIcon className="me-2" style={{height: '1em'}} />${slot.table.price_per_person} per person</li>
                    )}
                  </ul>
                  {slot.table.features && slot.table.features.length > 0 && (
                    <div className="mb-3">
                      <span className="fw-semibold text-dark me-2"><SparklesIcon style={{height: '1em'}} className="me-1" />Features:</span>
                      {slot.table.features.map((feature, index) => (
                        <span key={index} className="badge bg-primary me-2 mb-1">{feature}</span>
                      ))}
                    </div>
                  )}
                  <button
                    onClick={() => handleReservation(slot)}
                    disabled={!slot.available_for_reservation}
                    className={`btn w-100 fw-bold ${slot.available_for_reservation ? 'btn-primary' : 'btn-secondary disabled'}`}
                  >
                    {slot.available_for_reservation ? 'Book Now' : 'Not Available'}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Reservation Modal */}
      {selectedSlot && (
        <div className="modal fade show d-block" tabIndex="-1" style={{background: 'rgba(0,0,0,0.5)'}}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Book Reservation</h5>
                <button type="button" className="btn-close" aria-label="Close" onClick={() => setSelectedSlot(null)}></button>
              </div>
              <div className="modal-body">
                <div className="mb-3 p-2 bg-light rounded">
                  <p className="mb-1"><strong>{selectedSlot.table.name}</strong> - {selectedSlot.time_range}</p>
                  <p className="mb-0">{new Date(selectedSlot.date).toLocaleDateString()}</p>
                </div>
                <form onSubmit={submitReservation}>
                  <div className="mb-3">
                    <label className="form-label">Party Size</label>
                    <select
                      value={reservationForm.party_size}
                      onChange={(e) => setReservationForm(prev => ({
                        ...prev,
                        party_size: parseInt(e.target.value)
                      }))}
                      className="form-select"
                      required
                    >
                      {Array.from({ length: selectedSlot.table.capacity }, (_, i) => i + 1).map(num => (
                        <option key={num} value={num}>{num} {num === 1 ? 'person' : 'people'}</option>
                      ))}
                    </select>
                  </div>
                  <div className="mb-3">
                    <label className="form-label">Special Requests (Optional)</label>
                    <textarea
                      value={reservationForm.special_requests}
                      onChange={(e) => setReservationForm(prev => ({
                        ...prev,
                        special_requests: e.target.value
                      }))}
                      rows={3}
                      className="form-control"
                      placeholder="Any special requirements or requests..."
                    />
                  </div>
                  <div className="d-flex gap-2">
                    <button
                      type="button"
                      onClick={() => setSelectedSlot(null)}
                      className="btn btn-outline-secondary w-50"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      disabled={reservationLoading}
                      className="btn btn-primary w-50"
                    >
                      {reservationLoading ? 'Booking...' : 'Confirm Booking'}
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Home;
