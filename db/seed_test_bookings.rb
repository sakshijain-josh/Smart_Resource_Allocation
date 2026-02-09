# db/seeds/test_bookings.rb
user = User.find_by(role: 'employee') || User.first
admin = User.find_by(role: 'admin') || User.last
resources = Resource.limit(5)

puts "Seeding bookings for #{user.name} across #{resources.count} resources..."

(6..9).each do |day|
  date = Date.new(2026, 2, day)
  resources.each_with_index do |res, idx|
    # Create different status bookings for each day/resource
    status = case idx % 4
             when 0 then :approved
             when 1 then :auto_released
             when 2 then :pending
             when 3 then :expired
             end
    
    start_time = Time.zone.local(date.year, date.month, date.day, 10 + (idx % 5))
    end_time = start_time + 1.hour
    
    booking = Booking.new(
      user: user,
      resource: res,
      start_time: start_time,
      end_time: end_time,
      status: status
    )
    
    # Skip validation to allow historical data and weekends
    if booking.save(validate: false)
      puts "Created #{status} booking for #{date} - Resource: #{res.name}"
    else
      puts "Failed to create booking for #{date}: #{booking.errors.full_messages.join(', ')}"
    end
  end
end
