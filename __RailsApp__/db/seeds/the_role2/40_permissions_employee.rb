# db/seeds/the_role2/40_permissions_employee.rb
# exec: bin/rails runner db/seeds/the_role2/40_permissions_employee.rb
# Create permissions for Employee role

TheRole2::PermissionLog.actor = User.first
employee_role = TheRole2::Role.find_by!(name: 'Employee')

permissions_data = [
  # Departments permissions (work scope)
  { scope: 'work', resource: 'departments', action: 'index', value: true },
  { scope: 'work', resource: 'departments', action: 'show', value: true },
  { scope: 'work', resource: 'departments', action: 'create', value: false },
  { scope: 'work', resource: 'departments', action: 'edit', value: false },

  # Employees permissions (work scope)
  { scope: 'work', resource: 'employees', action: 'index', value: true },
  { scope: 'work', resource: 'employees', action: 'show', value: true },
  { scope: 'work', resource: 'employees', action: 'create', value: false },
  { scope: 'work', resource: 'employees', action: 'destroy', value: false },

  # Projects permissions (work scope)
  { scope: 'work', resource: 'projects', action: 'index', value: true },
  { scope: 'work', resource: 'projects', action: 'show', value: true },
  { scope: 'work', resource: 'projects', action: 'create', value: true },
  { scope: 'work', resource: 'projects', action: 'edit', value: true },
  { scope: 'work', resource: 'projects', action: 'update', value: true },
  { scope: 'work', resource: 'projects', action: 'destroy', value: false },

  # Posts permissions (global scope - as regular user)
  { scope: nil, resource: 'posts', action: 'index', value: true },
  { scope: nil, resource: 'posts', action: 'show', value: true },
  { scope: nil, resource: 'posts', action: 'create', value: true },

  # Comments permissions (global scope)
  { scope: nil, resource: 'comments', action: 'create', value: true }
]

permissions_data.each do |data|
  TheRole2::Permission.find_or_create_by!(
    holder: employee_role,
    scope: data[:scope],
    resource: data[:resource],
    action: data[:action]
  ) do |perm|
    perm.value = data[:value]
  end
end

puts "✓ Created #{permissions_data.length} permissions for Employee role"
