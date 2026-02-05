require "test_helper"

class BookingAutoReleaseJobTest < ActiveJob::TestCase
  test "should release expired bookings" do
    # Go to 10 AM to create the bookings
    travel_to Time.utc(2027, 1, 6, 10, 0, 0) do
      @expired_booking = create(:booking, start_time: Time.current + 5.minutes, end_time: Time.current + 15.minutes, status: :approved)
      @valid_booking = create(:booking, start_time: Time.current + 1.hour, end_time: Time.current + 2.hours, status: :approved)
    end

    # Travel to 11 AM - now @expired_booking is past due (finished at 10:15)
    travel_to Time.utc(2027, 1, 6, 11, 0, 0) do
      BookingAutoReleaseJob.perform_now
      assert_equal "auto_released", @expired_booking.reload.status
      assert_equal "approved", @valid_booking.reload.status
    end
    puts "✅ PASS: BookingAutoReleaseJob correctly triggers resource release (Edge Case: Expired Check-in)"
  end
end
