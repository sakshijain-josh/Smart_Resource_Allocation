class BookingAutoReleaseJob < ApplicationJob
  queue_as :default

  def perform
    Sidekiq.logger.info "Starting BookingAutoReleaseJob patrolling..."
    released_count = Booking.release_expired_bookings
    if released_count > 0
      Sidekiq.logger.info "SUCCESS: Released #{released_count} expired bookings."
    else
      Sidekiq.logger.info "No expired bookings found to release."
    end
  end
end
