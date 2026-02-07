class BookingMailer < ApplicationMailer
  # Admin email from ENV
  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL", "legacythreads11@gmail.com")

  def request_received(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.resource

    mail(to: ADMIN_EMAIL, subject: "New Booking Request: #{@resource.name} by #{@user.name}")
  end

  def status_updated(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.resource

    mail(to: @user.email, subject: "Booking Update: Your request for #{@resource.name} has been #{@booking.status}")
  end
end
