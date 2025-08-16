class User < ApplicationRecord
  has_secure_password
  
  has_many :reservations, dependent: :destroy
  has_many :reviews, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates_email_format_of :email
  validates :role, presence: true, inclusion: { in: %w[customer staff admin] }
  
  before_save { self.email = email.downcase }
  
  scope :customers, -> { where(role: 'customer') }
  scope :staff, -> { where(role: ['staff', 'admin']) }
  
  def customer?
    role == 'customer'
  end
  
  def staff?
    role == 'staff' || role == 'admin'
  end
  
  def admin?
    role == 'admin'
  end
end
