class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :time_slot
  has_one :table, through: :time_slot
  has_many :reviews, dependent: :destroy
  
  validates :party_size, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled completed] }
  validates :reservation_date, presence: true
  validate :party_size_fits_table
  validate :time_slot_available
  validate :future_reservation_date
  
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :pending, -> { where(status: 'pending') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :completed, -> { where(status: 'completed') }
  scope :upcoming, -> { where('reservation_date >= ?', Time.current) }
  scope :past, -> { where('reservation_date < ?', Time.current) }
  
  after_create :update_time_slot_availability
  after_update :handle_status_change
  
  def can_be_modified?
    pending? && reservation_date > 24.hours.from_now
  end
  
  def can_be_cancelled?
    (pending? || confirmed?) && reservation_date > 2.hours.from_now
  end
  
  def total_amount
    return 0 unless table&.price_per_person
    table.price_per_person * party_size
  end
  
  def pending?
    status == 'pending'
  end
  
  def confirmed?
    status == 'confirmed'
  end
  
  def cancelled?
    status == 'cancelled'
  end
  
  def completed?
    status == 'completed'
  end
  
  private
  
  def party_size_fits_table
    return unless time_slot&.table && party_size
    errors.add(:party_size, 'exceeds table capacity') if party_size > time_slot.table.capacity
  end
  
  def time_slot_available
    return unless time_slot
    errors.add(:time_slot, 'is not available') unless time_slot.available_for_reservation?
  end
  
  def future_reservation_date
    return unless reservation_date
    errors.add(:reservation_date, 'must be in the future') if reservation_date <= Time.current
  end
  
  def update_time_slot_availability
    time_slot.update(is_available: false) if confirmed? || pending?
  end
  
  def handle_status_change
    if status_changed?
      if cancelled? && time_slot.reservations.where(status: ['confirmed', 'pending']).empty?
        time_slot.update(is_available: true)
      elsif (confirmed? || pending?) && time_slot.is_available?
        time_slot.update(is_available: false)
      end
    end
  end
end
