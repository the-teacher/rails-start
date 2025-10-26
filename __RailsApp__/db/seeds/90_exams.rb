# db/seeds/90_exams.rb
# Create test exams

users = User.all

exams_data = [
  { user: users[0], title: 'Mathematics Final', description: 'Final exam for mathematics course', scheduled_at: 2.weeks.from_now, duration_minutes: 120, published: true },
  { user: users[1], title: 'Physics Midterm', description: 'Midterm exam for physics', scheduled_at: 1.week.from_now, duration_minutes: 90, published: true },
  { user: users[2], title: 'Chemistry Lab', description: 'Chemistry practical exam', scheduled_at: 3.weeks.from_now, duration_minutes: 180, published: false },
  { user: users[3], title: 'English Essay', description: 'Essay writing exam', scheduled_at: 10.days.from_now, duration_minutes: 120, published: true },
  { user: users[4], title: 'History Test', description: 'Historical events exam', scheduled_at: 5.days.from_now, duration_minutes: 60, published: false }
]

exams_data.each do |data|
  Exam.find_or_create_by!(user: data[:user], title: data[:title]) do |exam|
    exam.description = data[:description]
    exam.scheduled_at = data[:scheduled_at]
    exam.duration_minutes = data[:duration_minutes]
    exam.published = data[:published]
  end
end

puts "✓ Created #{exams_data.length} exams"
