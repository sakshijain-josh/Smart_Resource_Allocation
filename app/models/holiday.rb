class Holiday < ApplicationRecord
  # --- JSON Ordering ---
  def as_json(options = {})
    {
      id: id,
      name: name,
      holiday_date: holiday_date,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
