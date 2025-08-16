import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Add token to requests if available
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  register: (userData) => api.post('/auth/register', { user: userData }),
  login: (credentials) => api.post('/auth/login', credentials),
  logout: () => api.post('/auth/logout'),
  getCurrentUser: () => api.get('/auth/current_user'),
};

// Time Slots API
export const timeSlotsAPI = {
  getAvailable: (params) => api.get('/time_slots', { params }),
  getById: (id) => api.get(`/time_slots/${id}`),
};

// Reservations API
export const reservationsAPI = {
  getAll: (params) => api.get('/reservations', { params }),
  getById: (id) => api.get(`/reservations/${id}`),
  create: (reservationData) => api.post('/reservations', { reservation: reservationData }),
  update: (id, reservationData) => api.put(`/reservations/${id}`, { reservation: reservationData }),
  cancel: (id) => api.delete(`/reservations/${id}`),
};

// Reviews API
export const reviewsAPI = {
  getAll: (params) => api.get('/reviews', { params }),
  create: (reviewData) => api.post('/reviews', { review: reviewData }),
  update: (id, reviewData) => api.put(`/reviews/${id}`, { review: reviewData }),
  delete: (id) => api.delete(`/reviews/${id}`),
};

// Admin APIs
export const adminAPI = {
  tables: {
    getAll: (params) => api.get('/admin/tables', { params }),
    create: (tableData) => api.post('/admin/tables', { table: tableData }),
    getById: (id) => api.get(`/admin/tables/${id}`),
    update: (id, tableData) => api.put(`/admin/tables/${id}`, { table: tableData }),
    delete: (id) => api.delete(`/admin/tables/${id}`),
  },
  timeSlots: {
    create: (timeSlotData) => api.post('/admin/time_slots', { time_slot: timeSlotData }),
    update: (id, timeSlotData) => api.put(`/admin/time_slots/${id}`, { time_slot: timeSlotData }),
    delete: (id) => api.delete(`/admin/time_slots/${id}`),
  },
};

export default api;
