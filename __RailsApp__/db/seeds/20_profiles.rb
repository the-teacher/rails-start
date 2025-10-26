# db/seeds/profiles.rb
# Create test profiles for users

users = User.all

profiles_data = [
  { user: users[0], bio: 'System Administrator' },
  { user: users[1], bio: 'Software Developer' },
  { user: users[2], bio: 'Product Manager' },
  { user: users[3], bio: 'DevOps Engineer' },
  { user: users[4], bio: 'UX Designer' }
]

profiles_data.each do |data|
  Profile.find_or_create_by!(user: data[:user]) do |profile|
    profile.bio = data[:bio]
  end
end

puts "✓ Created #{profiles_data.length} profiles"
