class Table < ApplicationRecord
  has_many :time_slots, dependent: :destroy
  has_many :reservations, through: :time_slots
  
  validates :name, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validates :area, presence: true, inclusion: { in: %w[indoor outdoor private_dining] }
  validates :price_per_person, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  scope :by_capacity, ->(capacity) { where(capacity: capacity) }
  scope :by_area, ->(area) { where(area: area) }
  scope :available_on, ->(date) { joins(:time_slots).where(time_slots: { date: date, is_available: true }).distinct }
  
  def features_list
    return [] if features.blank?
    features.split(',').map(&:strip)
  end
  
  def features_list=(list)
    self.features = list.join(', ')
  end
end
