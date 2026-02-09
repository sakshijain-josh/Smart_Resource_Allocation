class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable,
         :jwt_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :trackable,
         :lockable,
         :timeoutable,
         jwt_revocation_strategy: JwtDenylist
  
  # Associations
  has_many :bookings, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Callbacks
  after_create_commit :send_welcome_email

  # Validations
  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: %w[employee admin] }

  # Role helper methods
  def admin?
    role == "admin"
  end

  def employee?
    role == "employee"
  end

  # --- JSON Ordering ---
  def as_json(options = {})
    {
      id: id,
      employee_id: employee_id,
      name: name,
      email: email,
      role: role,
      created_at: created_at&.in_time_zone&.strftime("%Y-%m-%dT%H:%M:%S"),
      updated_at: updated_at&.in_time_zone&.strftime("%Y-%m-%dT%H:%M:%S")
    }
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now
  end
end
