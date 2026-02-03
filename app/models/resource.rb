class Resource < ApplicationRecord
  # --- Validations ---
  # Name must be present and unique to avoid duplicate resources
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  # Resource type must be present and one of the allowed types
  validates :resource_type, presence: true, inclusion: { in: %w[meeting-room  laptop  phone turf] }
  
  # properties is a JSONB field, we can add validations for its structure if needed
  # For now it can be nil too as turf has no property
  # validates :properties (Removed because properties can be nil)

  # --- Callbacks ---
  # Ensure is_active is set to true by default if not specified
  after_initialize :set_default_active, if: :new_record?

  private

  def set_default_active
    self.is_active = true if is_active.nil?
  end
end
