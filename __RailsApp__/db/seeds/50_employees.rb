# db/seeds/50_employees.rb
# Create test employees (assign users to departments)

users = User.all
departments = Department.all

employees_data = [
  { user: users[0], department: departments[0] },
  { user: users[1], department: departments[0] },
  { user: users[2], department: departments[1] },
  { user: users[3], department: departments[2] },
  { user: users[4], department: departments[3] },
  { user: users[0], department: departments[2] }  # User 0 works in multiple departments
]

employees_data.each do |data|
  Employee.find_or_create_by!(user: data[:user], department: data[:department])
end

puts "✓ Created #{employees_data.length} employee assignments"
