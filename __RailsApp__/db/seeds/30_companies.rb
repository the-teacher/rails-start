# db/seeds/30_companies.rb
# Create test companies

companies_data = [
  { name: 'Tech Corp', description: 'Leading technology company' },
  { name: 'Digital Solutions', description: 'Software and consulting services' },
  { name: 'Innovation Labs', description: 'Research and development' }
]

companies_data.each do |data|
  Company.find_or_create_by!(name: data[:name]) do |company|
    company.description = data[:description]
  end
end

puts "✓ Created #{companies_data.length} companies"
