puts "Cleaning database..."
Notification.destroy_all
AuditLog.destroy_all
Booking.destroy_all
Resource.destroy_all
Holiday.destroy_all
User.destroy_all

puts "Seeding database..."

# 1. Users
admin = User.find_or_create_by!(email: 'legacythreads11@gmail.com') do |u|
  u.employee_id = 'EMP001'
  u.name = 'ADMIN'
  u.password = '123456789'
  u.password_confirmation = '123456789'
  u.role = 'admin'
end
puts "Created admin: #{admin.email}"

employee = User.find_or_create_by!(email: '1011jainsakshi@gmail.com') do |u|
  u.employee_id = 'EMP002'
  u.name = 'Sakshi Jain'
  u.password = '123456789'
  u.password_confirmation = '123456789'
  u.role = 'employee'
end
puts "Created employee: #{employee.email}"

# 2. Resources (Meeting Rooms)
meeting_rooms = [
  { name: 'Garnet', properties: { capacity: 4 }, location: 'Floor 6', resource_type: 'meeting-room' },
  { name: 'Topaz', properties: { capacity: 8 }, location: 'Floor 6', resource_type: 'meeting-room' },
  { name: 'Emerald', properties: { capacity: 8 }, location: 'Floor 6', resource_type: 'meeting-room' },
  { name: 'Citrine', properties: { capacity: 4 }, location: 'Floor 6', resource_type: 'meeting-room' },
  { name: 'Sapphire', properties: { capacity: 8 }, location: 'Floor 6', resource_type: 'meeting-room' }
]

meeting_rooms.each do |room|
  Resource.create!(room.merge(is_active: true))
end
puts "Seeded #{meeting_rooms.size} meeting rooms."

# 3. Resources (Turf)
Resource.create!(name: 'Turf', properties: { capacity: 20 }, location: 'Roof Top', resource_type: 'turf', is_active: true)
puts "Seeded Turf."

# 4. Resources (Laptops - 6 HP)
6.times do |i|
  Resource.create!(
    name: "HP Laptop #{i+1}",
    resource_type: 'laptop',
    location: 'IT Storage',
    properties: {
      os: 'Ubuntu 22.04',
      ram: '8GB',
      storage: '512GB SSD',
      serial_number: "HP-UBUNTU-#{1000 + i}"
    },
    is_active: true
  )
end
puts "Seeded 6 HP Laptops."

# 5. Resources (Laptops - 3 Dell)
3.times do |i|
  Resource.create!(
    name: "Dell Laptop #{i+1}",
    resource_type: 'laptop',
    location: 'IT Storage',
    properties: {
      os: 'Ubuntu 22.04',
      ram: '8GB',
      storage: '512GB SSD',
      serial_number: "DELL-UBUNTU-#{1000 + i}"
    },
    is_active: true
  )
end
puts "Seeded 3 Dell Laptops."


# 6. Resources (Laptops - 3 Lenovo)
3.times do |i|
  Resource.create!(
    name: "Lenovo Laptop #{i+1}",
    resource_type: 'laptop',
    location: 'IT Storage',
    properties: {
      os: 'Windows 11',
      ram: '16GB',
      storage: '1TB SSD',
      serial_number: "Lenovo-WINDOWS-#{1000 + i}"
    },
    is_active: true
  )
end
puts "Seeded 3 Lenovo Laptops."

# 7. Resources (Phones - 6 Mixed)
phones = [
  { name: 'iPhone 14 Pro', metadata: { os: 'iOS 17', ram: '16GB', storage: '256GB' } },
  { name: 'iPhone 15', metadata: { os: 'iOS 17', ram: '8GB', storage: '128GB' } },
  { name: 'Samsung Galaxy S23', metadata: { os: 'Android 13', ram: '12GB', storage: '256GB' } },
  { name: 'OnePlus 11', metadata: { os: 'OxygenOS 13', ram: '16GB', storage: '256GB' } },
  { name: 'Google Pixel 8', metadata: { os: 'Android 14', ram: '8GB', storage: '128GB' } },
  { name: 'iPhone 14', metadata: { os: 'iOS 16', ram: '6GB', storage: '128GB' } }
]

phones.each do |phone|
  Resource.create!(
    name: phone[:name],
    resource_type: 'phone',
    location: 'IT Storage',
    properties: phone[:metadata],
    is_active: true
  )
end
puts "Seeded 6 Phones (iOS & Android)."

# 8. Holidays (Indian National Holidays 2026)
holidays = [
  { name: 'Republic Day', holiday_date: '2026-01-26' },
  { name: 'Holi', holiday_date: '2026-03-03' },
  { name: 'Good Friday', holiday_date: '2026-04-03' },
  { name: 'Independence Day', holiday_date: '2026-08-15' },
  { name: 'Gandhi Jayanti', holiday_date: '2026-10-02' },
  { name: 'Diwali', holiday_date: '2026-11-08' },
  { name: 'Guru Nanak Jayanti', holiday_date: '2026-11-24' },
  { name: 'Christmas Day', holiday_date: '2026-12-25' }
]

holidays.each do |h|
  Holiday.create!(h)
end
puts "Seeded #{holidays.size} Indian National Holidays for 2026."

puts "Seeding completed successfully!"
