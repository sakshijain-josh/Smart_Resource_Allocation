require "rails_helper"

RSpec.describe Booking, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:resource) { create(:resource, resource_type: "meeting-room") }

  describe "validations" do
    it "is valid with proper start and end times" do
      # 10 AM on a Wednesday in 2027 (Jan 6 is Wednesday)
      date = Date.new(2027, 1, 6)
      start_time = Time.utc(date.year, date.month, date.day, 10, 0, 0)
      end_time = Time.utc(date.year, date.month, date.day, 11, 0, 0)

      travel_to start_time do
        booking = build(:booking, user: user, resource: resource, start_time: start_time, end_time: end_time)
        expect(booking).to be_valid
        puts "✅ PASS: Valid booking can be created within business hours (Normal Case)"
      end
    end

    it "is invalid with end_time before start_time" do
      start_time = Time.current + 2.hours
      end_time = Time.current + 1.hour
      booking = build(:booking, start_time: start_time, end_time: end_time)
      expect(booking).not_to be_valid
      expect(booking.errors[:end_time]).to include("must be after the start time")
      puts "✅ PASS: end_time must be after start_time (Edge Case: Negative Duration)"
    end

    it "is invalid in the past" do
      start_time = Time.current - 1.hour
      end_time = Time.current + 1.hour
      booking = build(:booking, start_time: start_time, end_time: end_time)
      expect(booking).not_to be_valid
      expect(booking.errors[:start_time]).to include("cannot be in the past")
      puts "✅ PASS: Past bookings are blocked (Edge Case: Time Travel)"
    end

    it "is invalid outside business hours" do
      # 7 AM
      date = Date.new(2027, 1, 6)
      start_time = Time.utc(date.year, date.month, date.day, 7, 0, 0)
      end_time = Time.utc(date.year, date.month, date.day, 8, 0, 0)

      travel_to start_time do
        booking = build(:booking, start_time: start_time, end_time: end_time)
        expect(booking).not_to be_valid
        expect(booking.errors[:base]).to include("Bookings are only allowed between 9:00 and 18:00")
        puts "✅ PASS: Outside business hours blocked (Edge Case: Night/Early Morning)"
      end
    end

    it "is invalid on weekends" do
      # Jan 9, 2027 is Saturday
      date = Date.new(2027, 1, 9)
      start_time = Time.utc(date.year, date.month, date.day, 10, 0, 0)
      end_time = Time.utc(date.year, date.month, date.day, 11, 0, 0)

      travel_to start_time - 1.day do # Travel to Friday
        booking = build(:booking, start_time: start_time, end_time: end_time)
        expect(booking).not_to be_valid
        expect(booking.errors[:base]).to include("Bookings are not allowed on Saturdays and Sundays")
        puts "✅ PASS: Weekends blocked (Edge Case: Saturday/Sunday)"
      end
    end

    it "is invalid on holidays" do
      holiday_date = Date.new(2027, 1, 1) # New Year
      create(:holiday, holiday_date: holiday_date, name: "New Year's Day")

      start_time = Time.utc(holiday_date.year, holiday_date.month, holiday_date.day, 10, 0, 0)
      end_time = Time.utc(holiday_date.year, holiday_date.month, holiday_date.day, 11, 0, 0)

      travel_to Time.utc(2026, 12, 31, 10, 0, 0) do
        booking = build(:booking, start_time: start_time, end_time: end_time)
        expect(booking).not_to be_valid
        expect(booking.errors[:base]).to include("Bookings are not allowed on National Holidays (New Year's Day)")
        puts "✅ PASS: National Holidays blocked (Edge Case: Holiday Conflict)"
      end
    end

    it "detects overlaps with approved bookings" do
      date = Date.new(2027, 1, 6)
      start1 = Time.utc(date.year, date.month, date.day, 10, 0, 0)
      end1 = Time.utc(date.year, date.month, date.day, 11, 0, 0)

      create(:booking, resource: resource, start_time: start1, end_time: end1, status: :approved)

      # Overlapping booking
      start2 = Time.utc(date.year, date.month, date.day, 10, 30, 0)
      end2 = Time.utc(date.year, date.month, date.day, 11, 30, 0)

      booking2 = build(:booking, resource: resource, start_time: start2, end_time: end2)
      expect(booking2).not_to be_valid
      expect(booking2.errors[:base]).to include("This resource is already booked (Approved) for the selected time slot")
      puts "✅ PASS: Overlapping approved bookings are blocked (Edge Case: Double Booking)"
    end
  end

  describe "callbacks" do
    it "creates an audit log on status change" do
      booking = create(:booking)
      expect {
        booking.update!(status: :approved)
      }.to change(AuditLog, :count).by(1)
      expect(AuditLog.last.new_status).to eq("approved")
      puts "✅ PASS: Audit log generated on status change (Normal Case: Compliance)"
    end
  end

  describe ".release_expired_bookings" do
    it "releases unclaimed bookings" do
      # Go to 10 AM to create
      travel_to Time.utc(2027, 1, 6, 10, 0, 0) do
        create(:booking, start_time: Time.current + 5.minutes, end_time: Time.current + 15.minutes, status: :approved)
      end

      # Travel to 11 AM
      travel_to Time.utc(2027, 1, 6, 11, 0, 0) do
        expect {
          Booking.release_expired_bookings
        }.to change { Booking.where(status: :auto_released).count }.by(1)
        puts "✅ PASS: release_expired_bookings correctly identifies and releases unclaimed resources (Edge Case: Auto-Release)"
      end
    end
  end
end
