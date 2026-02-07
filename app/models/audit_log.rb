class AuditLog < ApplicationRecord
  belongs_to :booking, optional: true
  belongs_to :resource, optional: true
  belongs_to :performer, class_name: "User", foreign_key: "performed_by"

  enum :old_status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    expired: 3,
    auto_released: 4,
    cancelled_by_user: 5
  }, prefix: :old

  enum :new_status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    expired: 3,
    auto_released: 4,
    cancelled_by_user: 5
  }, prefix: :new

  # --- JSON Ordering ---
  def as_json(options = {})
    {
      id: id,
      booking_id: booking_id,
      resource_id: resource_id,
      performed_by: performed_by,
      action: action,
      old_status: old_status,
      new_status: new_status,
      message: message,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
