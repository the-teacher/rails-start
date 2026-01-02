# Run this seed file with:
# rails runner db/seeds/posts.rb

puts "Creating posts..."

50.times do |i|
  Post.create!(
    title: "Post ##{i + 1}: Post Title for Caching Demo",
    body: "This is the body of post ##{i + 1}. It contains some sample text to demonstrate caching in a Rails application.",
    published: [true, false].sample
  )
end

puts "✅ Created #{Post.count} posts"
