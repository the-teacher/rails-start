# db/seeds/the_role2/10_roles.rb
# exec: bin/rails runner db/seeds/the_role2/10_roles.rb
# Create roles for the application

roles_data = [
  { name: 'User', description: 'Basic user role' },
  { name: 'Student', description: 'Student role for exams and courses' },
  { name: 'Employee', description: 'Employee role for company operations' }
]

roles_data.each do |data|
  TheRole2::Role.find_or_create_by!(name: data[:name]) do |role|
    role.description = data[:description]
  end
end

puts "✓ Created #{roles_data.length} roles"
