require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  setup do
    @booking = create(:booking)
  end

  test "request_received email" do
    email = BookingMailer.request_received(@booking)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [BookingMailer::ADMIN_EMAIL], email.to
    assert_match /New Booking Request/, email.subject
    assert_match @booking.user.name, email.body.encoded
    puts "✅ PASS: Admin receives notification of new booking request"
  end

  test "status_updated email" do
    @booking.update(status: :approved)
    email = BookingMailer.status_updated(@booking)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@booking.user.email], email.to
    assert_match /Booking Update/, email.subject
    assert_match "approved", email.body.encoded
    puts "✅ PASS: User receives notification when booking status changes"
  end
end
