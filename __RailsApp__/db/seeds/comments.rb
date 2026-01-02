# Run this seed file with:
# rails runner db/seeds/comments.rb

puts "Creating comments..."

posts = Post.all
authors = Author.all

if posts.empty? || authors.empty?
  puts "⚠️  No posts or authors found. Please run seeds for posts and authors first."
  exit
end

comments_templates = [
  "Great article! Very informative.",
  "Thanks for sharing this. It helped me a lot.",
  "Excellent explanation of the topic.",
  "I have a question about this approach.",
  "This is exactly what I was looking for.",
  "Very clear and well-written post.",
  "Could you provide more examples?",
  "Interesting perspective on this topic."
]

posts.each do |post|
  rand(2..8).times do
    Comment.create!(
      post: post,
      author: authors.sample,
      body: comments_templates.sample
    )
  end
end

puts "✅ Created #{Comment.count} comments"
