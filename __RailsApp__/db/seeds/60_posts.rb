# db/seeds/60_posts.rb
# Create test posts

users = User.all

posts_data = [
  { user: users[0], title: 'Welcome to our blog', content: 'This is the first post', published: true },
  { user: users[1], title: 'Ruby on Rails Tips', content: 'Some useful Rails tips and tricks', published: true },
  { user: users[2], title: 'Web Development Trends', content: 'Latest trends in web development', published: false },
  { user: users[3], title: 'DevOps Best Practices', content: 'Best practices for DevOps engineers', published: true },
  { user: users[4], title: 'Design Principles', content: 'Fundamental UX/UI design principles', published: false }
]

posts_data.each do |data|
  Post.find_or_create_by!(user: data[:user], title: data[:title]) do |post|
    post.content = data[:content]
    post.published = data[:published]
  end
end

puts "✓ Created #{posts_data.length} posts"
