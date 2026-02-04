class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :booking, optional: true

  # --- JSON Ordering ---
  def as_json(options = {})
    {
      id: id,
      user_id: user_id,
      booking_id: booking_id,
      notification_type: notification_type,
      channel: channel,
      message: message, # Wait, I don't see message in schema for notification, but let's check
      is_read: is_read,
      sent_at: sent_at,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
