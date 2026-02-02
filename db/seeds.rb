puts "Seeding database..."

admin = User.find_or_initialize_by(email: 'admin@josh.com')
admin.assign_attributes(
  employee_id: 'EMP001',
  name: 'Admin',
  password: 'admin123456',
  password_confirmation: 'admin123456',
  role: :admin,
  failed_attempts: 0,
  sign_in_count: 0
)
admin.save!
puts "Created/Updated admin user: #{admin.email}"

employee = User.find_or_initialize_by(email: 'sakshi@josh.com')
employee.assign_attributes(
  employee_id: 'EMP002',
  name: 'Sakshi',
  password: 'employee123456',
  password_confirmation: 'employee123456',
  role: :employee,
  failed_attempts: 0,
  sign_in_count: 0
)
employee.save!
puts "Created/Updated employee user: #{employee.email}"

puts "Seeding completed!"