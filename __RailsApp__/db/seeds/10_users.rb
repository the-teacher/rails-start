# db/seeds/users.rb
# Create test users

users_data = [
  { email: 'admin@example.com', name: 'Admin User' },
  { email: 'john@example.com', name: 'John Doe' },
  { email: 'jane@example.com', name: 'Jane Smith' },
  { email: 'bob@example.com', name: 'Bob Johnson' },
  { email: 'alice@example.com', name: 'Alice Williams' }
]

users_data.each do |data|
  User.find_or_create_by!(email: data[:email]) do |user|
    user.name = data[:name]
  end
end

puts "✓ Created #{users_data.length} users"
