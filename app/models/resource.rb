class Resource < ApplicationRecord
  # --- Associations ---
  has_many :bookings

  # --- Validations ---
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :resource_type, presence: true, inclusion: { in: %w[meeting-room laptop phone turf] }

  # Custom validation for Turf
  validate :validate_turf_uniqueness, if: :turf?
  before_validation :force_turf_name, if: :turf?

  # --- Callbacks ---
  after_initialize :set_default_active, if: :new_record?

  # --- Public Methods ---

  # Calculate available time slots for a given date
  # @param date [Date, String] The date to check availability (defaults to today)
  # @param duration_hours [Integer] Duration of each slot in hours (defaults to 1)
  # @return [Array<Hash>] Array of time slots with availability status
  def available_slots(date = Date.today, duration_hours = 1)
    date = Date.parse(date.to_s) unless date.is_a?(Date)

    # Working hours from ENV
    work_start_hour = ENV.fetch("BUSINESS_HOURS_START", 9).to_i
    work_end_hour = ENV.fetch("BUSINESS_HOURS_END", 18).to_i

    slots = []
    # Use Time.utc to ensure we stay on the correct day
    current_time = Time.utc(date.year, date.month, date.day, work_start_hour)
    end_time = Time.utc(date.year, date.month, date.day, work_end_hour)

    # Get all approved bookings for this resource on the given date
    approved_bookings = bookings.where(status: :approved)
                                .where("DATE(start_time) = ?", date)
                                .order(:start_time)

    while current_time < end_time
      slot_end = current_time + duration_hours.hours
      break if slot_end > end_time

      # Check if this slot conflicts with any approved booking
      conflicting_booking = approved_bookings.find do |booking|
        # Check for any overlap
        (current_time < booking.end_time) && (slot_end > booking.start_time)
      end

      slot_info = {
        start_time: current_time,
        end_time: slot_end,
        available: conflicting_booking.nil?
      }

      # Add booking details if slot is occupied
      if conflicting_booking
        slot_info[:booking_id] = conflicting_booking.id
        slot_info[:booked_by] = conflicting_booking.user.name
        slot_info[:booking_status] = conflicting_booking.status
      end

      slots << slot_info
      current_time = slot_end
    end

    slots
  end

  # --- JSON Ordering ---
  def as_json(options = {})
    {
      id: id,
      name: name,
      resource_type: resource_type,
      description: description,
      location: location,
      is_active: is_active,
      properties: properties,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def turf?
    resource_type == "turf"
  end

  def force_turf_name
    self.name = "Turf"
  end

  def validate_turf_uniqueness
    if Resource.where(resource_type: "turf").where.not(id: id).exists?
      errors.add(:resource_type, "only one Turf resource is allowed")
    end
  end

  def set_default_active
    self.is_active = true if is_active.nil?
  end
end
