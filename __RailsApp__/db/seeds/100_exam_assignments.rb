# db/seeds/100_exam_assignments.rb
# Assign students to exams

students = Student.all
exams = Exam.all

exam_assignments_data = [
  { student: students[0], exam: exams[0] },
  { student: students[0], exam: exams[1] },
  { student: students[1], exam: exams[0] },
  { student: students[2], exam: exams[1] },
  { student: students[2], exam: exams[2] },
  { student: students[3], exam: exams[2] },
  { student: students[4], exam: exams[3] },
  { student: students[4], exam: exams[4] }
]

exam_assignments_data.each do |data|
  ExamAssignment.find_or_create_by!(student: data[:student], exam: data[:exam])
end

puts "✓ Created #{exam_assignments_data.length} exam assignments"
