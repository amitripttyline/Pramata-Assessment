class TimeSlot < ApplicationRecord
  belongs_to :table
  has_many :reservations, dependent: :destroy
  
  validates :start_time, :end_time, :date, presence: true
  validates :is_available, inclusion: { in: [true, false] }
  validate :end_time_after_start_time
  validate :valid_date
  validate :valid_time_range
  
  scope :available, -> { where(is_available: true) }
  scope :on_date, ->(date) { where(date: date) }
  scope :for_capacity, ->(party_size) { joins(:table).where('tables.capacity >= ?', party_size) }
  scope :in_area, ->(area) { joins(:table).where(tables: { area: area }) }
  scope :upcoming, -> { where('date >= ?', Date.current) }
  
  def available_for_reservation?
    is_available && reservations.where(status: ['confirmed', 'pending']).empty?
  end
  
  def duration_minutes
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.minute).to_i
  end
  
  def time_range
    return '' unless start_time && end_time
    "#{start_time.strftime('%I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
  end
  
  private
  
  def end_time_after_start_time
    return unless start_time && end_time
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end
  
  def valid_date
    return unless date
    errors.add(:date, 'cannot be in the past') if date < Date.current
  end
  
  def valid_time_range
    return unless start_time && end_time
    duration = ((end_time - start_time) / 1.hour)
    errors.add(:end_time, 'reservation duration must be between 1 and 4 hours') unless (1..4).include?(duration)
  end
end
