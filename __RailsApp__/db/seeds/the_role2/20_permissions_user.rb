# db/seeds/the_role2/20_permissions_user.rb
# exec: bin/rails runner db/seeds/the_role2/20_permissions_user.rb
# Create permissions for User role

TheRole2::PermissionLog.current_actor = User.first
user_role = TheRole2::Role.find_by!(name: 'User')

# Scopes: nil (global), university, work
# Resources & Actions based on typical Rails controllers

permissions_data = [
  # Posts permissions (global scope)
  { scope: nil, resource: 'posts', action: 'index', value: true },
  { scope: nil, resource: 'posts', action: 'show', value: true },
  { scope: nil, resource: 'posts', action: 'create', value: true },
  { scope: nil, resource: 'posts', action: 'edit', value: false },
  { scope: nil, resource: 'posts', action: 'destroy', value: false },

  # Comments permissions (global scope)
  { scope: nil, resource: 'comments', action: 'index', value: true },
  { scope: nil, resource: 'comments', action: 'create', value: true },
  { scope: nil, resource: 'comments', action: 'destroy', value: false },

  # Profile permissions (global scope)
  { scope: nil, resource: 'profiles', action: 'show', value: true },
  { scope: nil, resource: 'profiles', action: 'edit', value: true },
  { scope: nil, resource: 'profiles', action: 'update', value: true }
]

permissions_data.each do |data|
  TheRole2::Permission.find_or_create_by!(
    holder: user_role,
    scope: data[:scope],
    resource: data[:resource],
    action: data[:action]
  ) do |perm|
    perm.value = data[:value]
  end
end

puts "✓ Created #{permissions_data.length} permissions for User role"
