# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# rails db:drop && rails db:create && rails db:migrate && rails db:seed

puts "🌱 Starting seed process..."

# Load authors first
load Rails.root.join('db', 'seeds', 'authors.rb')

# Then load posts
load Rails.root.join('db', 'seeds', 'posts.rb')

# Then load comments
load Rails.root.join('db', 'seeds', 'comments.rb')

puts "✅ Seeding completed successfully!"