# TheRole2::Permission

TheRole2::Permission is the model that represents a permission in the Context-Aware RBAC system provided by TheRole2.
Permissions define specific actions that can be performed within the application, with support for scopes, time-based activation, and audit logging.

## Attributes

### Core Permission Definition

- **holder** (polymorphic relation = `holder_id`, `holder_type`): Identifies who owns this permission (User, Company, Employee, Student etc.).

- **`scope`** (string, optional): Domain context for the permission. Can reflect a part of your system within which the permission applies. For example, if a project consists of several subsystems (login, cms, forum, etc.), you can use scope to separate permissions across these subsystems. Can be `nil` for simple systems.

  - Examples: `login`, `forum`, `cms`, `billing`
  - Auto-normalized: `'Work System'` → `'work_system'`

- **`resource`** (string, not null): Identifies the target entity or object to which the permission applies. In Ruby on Rails controllers, this typically corresponds to a controller or model.

  - Examples: `posts`, `comments`, `departments`, `exams`
  - Auto-normalized: `'Forum Posts'` → `forum_posts`

- **`action`** (string, not null): Identifies the specific operation that can be performed on the resource. In Ruby on Rails, this typically corresponds to controller action names.

  - Examples:
    - Standard CRUD actions: `index`, `show`, `create`, `update`, `destroy`
  - Custom actions: `approve`, `publish`, `archive`, `unarchive`, `pin`, etc.
  - Auto-normalized: `Approve Post` → `approve_post`

### Control Flags

- **`value`** (boolean, not null, default: false): Allows or denies the action.

  - `true` — Permission is **allowed**
  - `false` — Permission is **denied** (explicit deny, overrides role defaults)

- **`enabled`** (boolean, not null, default: true): Master switch for the permission.
  - `true` — Permission is active
  - `false` — Permission is disabled (treated as non-existent)

### Time-Based Activation

- **`starts_at`** (datetime, optional): When the permission becomes active.

  - `nil` — No start restriction (available immediately)
  - Example: `Date.today` — Permission active from today onwards

- **`ends_at`** (datetime, optional): When the permission expires.

  - `nil` — No end restriction (active indefinitely)
  - Example: `Date.today + 30.days` — Permission expires in 30 days

- **`description`** (text, optional): Human-readable explanation of what the permission does.

  - Example: `"Allows users to create new blog posts in the forum"`

- **`created_at`**, **`updated_at`** (datetime): Timestamps for record creation and last update.

## Permission Key Format

The full permission key is constructed as: **`scope::resource::action`**

Examples:

- `'posts::index'` — Global scope (nil → omitted)
- `'posts::create'`
- `'comments::destroy'`
- `'university::exams::show'` — University scope
- `'work::departments::index'` — Work scope
- `'work::employees::create'`

## Key Methods

### Scopes

```ruby
Permission.enabled                    # Only enabled permissions
Permission.effective                  # Enabled + within time window
Permission.by_key('posts::create')    # Find by compound key
```

### Instance Methods

```ruby
permission = TheRole2::Permission.first

permission.full_key                  # Returns "scope::resource::action"
permission.title                     # Alias for full_key
permission.effective?                # true if enabled and within time window
Permission.parse_key(key)            # Parse "posts::create" → [nil, 'posts', 'create']
```

## Usage Examples

### Pattern 1: Permissions on Role (Traditional RBAC)

```ruby
# Set the current user as the actor for audit trail
TheRole2::PermissionLog.current_actor = User.first

# Get or create a role
user_role = TheRole2::Role.create_or_find_by!(name: 'User')

# Create permissions on the role
user_role.permissions.create!(
  scope: nil,
  resource: 'posts',
  action: 'create',
  value: true,
  enabled: true
)

user_role.permissions.create!(
  scope: nil,
  resource: 'posts',
  action: 'destroy',
  value: false,  # Deny this action
  enabled: true
)

# Preload and check
user_role.permissions_preload!
user_role.permission_allowed?('posts::create')   # => true
user_role.permission_allowed?('posts::destroy')  # => false
```

### Pattern 2: Direct Permissions on Any Model (HasPermissions Concern)

**Models must include `TheRole2::HasPermissions` concern:**

```ruby
class User < ApplicationRecord
  include TheRole2::HasPermissions
end

class Company < ApplicationRecord
  include TheRole2::HasPermissions
end
```

Then use the model's permission methods:

```ruby
# Set actor for auditing
TheRole2::PermissionLog.current_actor = User.first

user = User.find(1)

# Create permissions directly on the user
user.permissions.create!(
  resource: 'posts',
  action: 'create',
  scope: nil,
  value: true,
  description: 'User can create posts'
)

user.permissions.create!(
  resource: 'comments',
  action: 'destroy',
  scope: nil,
  value: false
)

user.permissions.create!(
  resource: 'exams',
  action: 'show',
  scope: 'university',
  value: true
)

# Check permissions
user.preload_permissions!
user.has_permission?('posts::create')              # => true
user.has_permission?('comments::destroy')          # => false
user.has_permission?('university::exams::show')    # => true

# View all permissions
user.permissions
# => [#<Permission id: 1, holder_type: "User", holder_id: 1, ...>,
#     #<Permission id: 2, holder_type: "User", holder_id: 1, ...>]

# Revoke permission
user.revoke_permission!('posts::create')

# Disable permission (keep it but don't apply)
user.disable_permission!('university::exams::show')

# Re-enable permission
user.enable_permission!('university::exams::show')
```

### Pattern 3: Permissions on Company

```ruby
company = Company.find(1)
TheRole2::PermissionLog.current_actor = User.first

# Create work-scoped permissions on company
company.permissions.create!(
  resource: 'departments',
  action: 'create',
  scope: 'work',
  value: true
)

company.permissions.create!(
  resource: 'employees',
  action: 'manage',
  scope: 'work',
  value: true
)

# Check
company.preload_permissions!
company.has_permission?('work::departments::create')  # => true
company.has_permission?('work::employees::manage')    # => true
```

### Pattern 4: Time-Limited Permissions

```ruby
user = User.first
TheRole2::PermissionLog.current_actor = User.first

# Permission valid for next 30 days only
user.permissions.create!(
  resource: 'reports',
  action: 'export',
  scope: nil,
  value: true,
  starts_at: Date.today,
  ends_at: Date.today + 30.days,
  description: 'Temporary access for quarterly reporting'
)

user.preload_permissions!
user.has_permission?('reports::export')  # => true (if within time window)
```

### Pattern 5: List All Permissions

```ruby
user = User.first

# Get all permissions for this user
user.permissions
# => [#<Permission ...>, #<Permission ...>, ...]

# Check all permissions grouped by scope/resource
user.permissions.includes(:logs).map do |p|
  puts "#{p.full_key} => #{p.value}"
end

# Output:
# posts::create => true
# posts::destroy => false
# university::exams::show => true
```
