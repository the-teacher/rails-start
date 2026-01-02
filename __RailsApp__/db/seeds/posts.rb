# Run this seed file with:
# rails runner db/seeds/posts.rb

puts "Creating posts..."

authors = Author.all

if authors.empty?
  puts "⚠️  No authors found. Please run: rails runner db/seeds/authors.rb"
  exit
end

posts_data = [
  "Introduction to Ruby on Rails",
  "Understanding MVC Architecture",
  "Database Optimization Techniques",
  "RESTful API Design Patterns",
  "Testing Best Practices",
  "Caching Strategies in Rails",
  "Security Best Practices",
  "Performance Optimization Tips",
  "Background Job Processing",
  "Deploying Rails Applications",
  "Active Record Associations Guide",
  "Rails Routing Deep Dive",
  "Action Cable Real-time Features",
  "Rails API Mode Development",
  "Background Jobs with Sidekiq",
  "Authentication with Devise",
  "Authorization Patterns",
  "Database Indexing Strategies",
  "N+1 Query Problem Solutions",
  "Rails Asset Pipeline",
  "Webpack Integration in Rails",
  "Docker for Rails Applications",
  "Continuous Integration Setup",
  "Rails Testing with RSpec",
  "Integration Testing Best Practices",
  "Rails Console Tips and Tricks",
  "Active Storage File Uploads",
  "Action Mailer Configuration",
  "Rails Internationalization (i18n)",
  "Rails Security Vulnerabilities",
  "CORS Configuration in Rails",
  "GraphQL with Rails",
  "Rails Service Objects Pattern",
  "Form Objects in Rails",
  "Rails Presenters and Decorators",
  "Polymorphic Associations",
  "Single Table Inheritance",
  "Multi-tenancy in Rails",
  "Rails Performance Monitoring",
  "Memory Optimization Techniques",
  "Rails Caching Layers",
  "Redis Integration",
  "Elasticsearch with Rails",
  "Rails Concerns Best Practices",
  "Active Job Queue Adapters",
  "Rails Engines Development",
  "Rails API Documentation",
  "Hotwire and Turbo Frames",
  "Stimulus JS Integration",
  "Rails 8 New Features"
]

50.times do |i|
  title = i < posts_data.length ? posts_data[i] : "Post ##{i + 1}"

  Post.create!(
    title: title,
    body: "This is the content of the post about #{title.downcase}. It contains detailed information and examples. The article covers important aspects and provides practical insights for developers.",
    published: [true, false].sample,
    author: authors.sample
  )
end

puts "✅ Created #{Post.count} posts"
