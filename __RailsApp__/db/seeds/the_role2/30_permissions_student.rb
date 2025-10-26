# db/seeds/the_role2/30_permissions_student.rb
# exec: bin/rails runner db/seeds/the_role2/30_permissions_student.rb
# Create permissions for Student role

TheRole2::PermissionLog.actor = User.first
student_role = TheRole2::Role.find_by!(name: 'Student')

permissions_data = [
  # Exams permissions (university scope)
  { scope: 'university', resource: 'exams', action: 'index', value: true },
  { scope: 'university', resource: 'exams', action: 'show', value: true },
  { scope: 'university', resource: 'exams', action: 'create', value: false },
  { scope: 'university', resource: 'exams', action: 'edit', value: false },
  { scope: 'university', resource: 'exams', action: 'destroy', value: false },

  # Courses permissions (university scope)
  { scope: 'university', resource: 'courses', action: 'index', value: true },
  { scope: 'university', resource: 'courses', action: 'show', value: true },
  { scope: 'university', resource: 'courses', action: 'create', value: false },

  # Posts permissions (global scope - as regular user)
  { scope: nil, resource: 'posts', action: 'index', value: true },
  { scope: nil, resource: 'posts', action: 'show', value: true },
  { scope: nil, resource: 'posts', action: 'create', value: true },

  # Comments permissions (global scope)
  { scope: nil, resource: 'comments', action: 'create', value: true }
]

permissions_data.each do |data|
  TheRole2::Permission.find_or_create_by!(
    holder: student_role,
    scope: data[:scope],
    resource: data[:resource],
    action: data[:action]
  ) do |perm|
    perm.value = data[:value]
  end
end

puts "✓ Created #{permissions_data.length} permissions for Student role"
