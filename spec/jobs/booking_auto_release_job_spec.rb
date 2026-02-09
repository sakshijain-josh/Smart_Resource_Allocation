require "rails_helper"

RSpec.describe BookingAutoReleaseJob, type: :job do
  describe "#perform" do
    it "calls Booking.release_expired_bookings" do
      expect(Booking).to receive(:release_expired_bookings).and_return(1)
      BookingAutoReleaseJob.new.perform
    end
  end
end
