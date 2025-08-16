class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reservation
  
  validates :rating, presence: true, numericality: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :reservation_id, message: "can only review each reservation once" }
  validate :reservation_must_be_completed
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :with_comments, -> { where.not(comment: [nil, '']) }
  
  def self.average_rating
    average(:rating)&.round(1) || 0.0
  end
  
  def self.rating_distribution
    group(:rating).count
  end
  
  private
  
  def reservation_must_be_completed
    return unless reservation
    errors.add(:reservation, 'must be completed before reviewing') unless reservation.completed?
  end
end
