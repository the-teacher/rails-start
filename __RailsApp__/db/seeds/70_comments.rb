# db/seeds/70_comments.rb
# Create test comments on posts

users = User.all
posts = Post.all

comments_data = [
  { post: posts[0], user: users[1], content: 'Great post! Thanks for sharing.' },
  { post: posts[0], user: users[2], content: 'Very informative, appreciated!' },
  { post: posts[1], user: users[0], content: 'Excellent tips, bookmarking this.' },
  { post: posts[1], user: users[3], content: 'This helped me a lot!' },
  { post: posts[3], user: users[4], content: 'Best practices indeed!' }
]

comments_data.each do |data|
  Comment.find_or_create_by!(post: data[:post], user: data[:user], content: data[:content])
end

puts "✓ Created #{comments_data.length} comments"
