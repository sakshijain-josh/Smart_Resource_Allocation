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

  # Validations
  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: %w[employee admin] }

  # Role helper methods
  def admin?
    role == 'admin'
  end

  def employee?
    role == 'employee'
  end
end
