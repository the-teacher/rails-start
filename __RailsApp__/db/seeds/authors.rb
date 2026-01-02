# Run this seed file with:
# rails runner db/seeds/authors.rb

puts "Creating authors..."

authors_data = [
  { name: "John Smith", email: "john.smith@example.com", bio: "Software developer with 10 years of experience in Ruby on Rails." },
  { name: "Jane Doe", email: "jane.doe@example.com", bio: "Full-stack developer and technical writer." },
  { name: "Mike Johnson", email: "mike.j@example.com", bio: "Senior Rails developer and open source contributor." },
  { name: "Sarah Williams", email: "sarah.w@example.com", bio: "Web developer specializing in backend technologies." },
  { name: "Robert Brown", email: "robert.brown@example.com", bio: "Tech lead with passion for clean code and testing." },
  { name: "Emily Davis", email: "emily.davis@example.com", bio: "Rails developer and database optimization expert." },
  { name: "David Wilson", email: "david.wilson@example.com", bio: "Software engineer with focus on web applications." },
  { name: "Lisa Anderson", email: "lisa.a@example.com", bio: "Full-stack developer and UI/UX enthusiast." },
  { name: "James Taylor", email: "james.taylor@example.com", bio: "Backend developer with experience in scaling applications." },
  { name: "Maria Garcia", email: "maria.garcia@example.com", bio: "Rails developer and agile methodology advocate." }
]

authors_data.each do |data|
  Author.create!(data)
end

puts "✅ Created #{Author.count} authors"
