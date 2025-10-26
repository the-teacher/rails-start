# db/seeds/80_students.rb
# Create test students

users = User.all

students_data = [
  { user: users[0], student_id: 'STU001', grade: 'A' },
  { user: users[1], student_id: 'STU002', grade: 'B' },
  { user: users[2], student_id: 'STU003', grade: 'A' },
  { user: users[3], student_id: 'STU004', grade: 'C' },
  { user: users[4], student_id: 'STU005', grade: 'B' }
]

students_data.each do |data|
  Student.find_or_create_by!(student_id: data[:student_id]) do |student|
    student.user = data[:user]
    student.grade = data[:grade]
  end
end

puts "✓ Created #{students_data.length} students"
