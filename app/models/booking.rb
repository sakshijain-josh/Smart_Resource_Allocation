class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  has_many :audit_logs, dependent: :destroy
  
  # Virtual attribute to track who performed the status change
  attr_accessor :performer_id

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    expired: 3,
    auto_released: 4,
    cancelled_by_user: 5
  }

  # --- Callbacks ---
  after_initialize :set_default_status, if: :new_record?
  before_save :set_timestamps_on_status_change
  after_save :create_audit_log, if: :saved_change_to_status?
  
  # Notification hooks
  after_create_commit :notify_admin_of_request
  after_update_commit :notify_user_of_status_change, if: -> { saved_change_to_status? || saved_change_to_start_time? || saved_change_to_end_time? || saved_change_to_resource_id? }

  # --- Validations ---
  validates :status, presence: true
  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :not_past_booking, if: :new_record?
  validate :same_day_booking
  validate :within_business_hours
  validate :not_weekend
  validate :not_holiday
  validate :no_overlap, if: -> { status.nil? || approved? || pending? }

  # --- JSON Ordering ---
  def as_json(options = {})
    {
      id: id,
      user_id: user_id,
      employee_id: user&.employee_id,
      employee_name: user&.name,
      resource_id: resource_id,
      resource_name: resource&.name,
      status: status,
      start_time: start_time,
      end_time: end_time,
      approved_at: approved_at,
      cancelled_at: cancelled_at,
      checked_in_at: checked_in_at,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  # --- Suggestion Logic ---

  # Suggest other resources of the same type available during this time
  def suggest_alternative_resources
    Resource.where(resource_type: resource.resource_type)
            .where.not(id: resource_id)
            .where(is_active: true)
            .reject do |r|
              r.bookings.where(status: :approved)
                        .where('start_time < ? AND end_time > ?', end_time, start_time)
                        .exists?
            end
  end

  # Suggest other available time slots for this resource on the same day
  def suggest_alternative_slots
    resource.available_slots(start_time.to_date).select { |s| s[:available] }
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def not_past_booking
    return if start_time.blank?
    if start_time < Time.current
      errors.add(:start_time, "cannot be in the past")
    end
  end

  def same_day_booking
    return if start_time.blank? || end_time.blank?
    if start_time.to_date != end_time.to_date
      errors.add(:base, "Booking must start and end on the same day")
    end
  end

  def within_business_hours
    return if start_time.blank? || end_time.blank?
    
    # Check if start/end time is within 9 AM to 6 PM
    if start_time.hour < 9 || end_time.hour > 18 || (end_time.hour == 18 && end_time.min > 0)
      errors.add(:base, "Bookings are only allowed between 9:00 AM and 6:00 PM")
    end
  end

  def not_weekend
    return if start_time.blank?
    if start_time.saturday? || start_time.sunday?
      errors.add(:base, "Bookings are not allowed on Saturdays and Sundays")
    end
  end

  def not_holiday
    return if start_time.blank?
    if Holiday.exists?(holiday_date: start_time.to_date)
      holiday = Holiday.find_by(holiday_date: start_time.to_date)
      errors.add(:base, "Bookings are not allowed on National Holidays (#{holiday.name})")
    end
  end

  def no_overlap
    return if start_time.blank? || end_time.blank? || resource.blank?

    # Only block if there is an ALREADY APPROVED booking that overlaps
    overlapping_bookings = resource.bookings
                                   .where(status: :approved)
                                   .where.not(id: id)
                                   .where('start_time < ? AND end_time > ?', end_time, start_time)

    if overlapping_bookings.exists?
      errors.add(:base, "This resource is already booked (Approved) for the selected time slot")
    end
  end

  def set_default_status
    self.status ||= :pending
  end

  def set_timestamps_on_status_change
    if status_changed?
      case status.to_sym
      when :approved
        self.approved_at = Time.current
      when :cancelled_by_user
        self.cancelled_at = Time.current
      end
    end
  end

  def create_audit_log
    AuditLog.create!(
      booking: self,
      resource: resource,
      performed_by: performer_id || user_id,
      action: "status_change",
      old_status: saved_change_to_status[0],
      new_status: saved_change_to_status[1],
      message: "Status changed from #{saved_change_to_status[0]} to #{saved_change_to_status[1]}"
    )
  end

  def notify_admin_of_request
    BookingMailer.request_received(self).deliver_now
  end

  def notify_user_of_status_change
    BookingMailer.status_updated(self).deliver_now
  end

  # --- Class Methods for Maintenance ---

  def self.release_expired_bookings
    # Find active, approved bookings where start_time was more than 15 mins ago
    # but checked_in_at is still nil
    threshold = 15.minutes.ago
    expired_bookings = where(status: :approved, checked_in_at: nil)
                       .where('start_time < ?', threshold)

    count = 0
    expired_bookings.find_each do |booking|
      booking.update(status: :auto_released, admin_note: "Auto-released due to no check-in within 15 mins")
      count += 1
    end
    count
  end
end
