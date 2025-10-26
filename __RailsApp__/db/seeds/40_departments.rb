# db/seeds/40_departments.rb
# Create test departments

companies = Company.all

departments_data = [
  { company: companies[0], name: 'Engineering', description: 'Software development team' },
  { company: companies[0], name: 'Sales', description: 'Sales and business development' },
  { company: companies[1], name: 'Backend', description: 'Backend development' },
  { company: companies[1], name: 'Frontend', description: 'Frontend development' },
  { company: companies[2], name: 'Research', description: 'Research department' }
]

departments_data.each do |data|
  Department.find_or_create_by!(company: data[:company], name: data[:name]) do |dept|
    dept.description = data[:description]
  end
end

puts "✓ Created #{departments_data.length} departments"
