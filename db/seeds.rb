# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create admin user
admin = User.find_or_create_by!(email: 'admin@josh.com') do |user|
  user.employee_id = 'EMP001'
  user.name = 'Admin'
  user.password = 'admin123456'
  user.password_confirmation = 'admin123456'
  user.role = :admin
end
puts "Created admin user: #{admin.email}"

# Create employee user
employee = User.find_or_create_by!(email: 'sakshi@josh.com.com') do |user|
  user.employee_id = 'EMP002'
  user.name = 'Sakshi'
  user.password = 'employee123456'
  user.password_confirmation = 'employee123456'
  user.role = :employee
end
puts "Created employee user: #{employee.email}"

puts "Seeding completed!"
