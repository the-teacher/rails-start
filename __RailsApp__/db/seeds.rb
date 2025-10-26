# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load seeds from individual files in order

# Base application data (required before TheRole2 seeds)
load(Rails.root.join('db', 'seeds', '10_users.rb'))
load(Rails.root.join('db', 'seeds', '20_profiles.rb'))
load(Rails.root.join('db', 'seeds', '30_companies.rb'))
load(Rails.root.join('db', 'seeds', '40_departments.rb'))
load(Rails.root.join('db', 'seeds', '50_employees.rb'))
load(Rails.root.join('db', 'seeds', '60_posts.rb'))
load(Rails.root.join('db', 'seeds', '70_comments.rb'))
load(Rails.root.join('db', 'seeds', '80_students.rb'))
load(Rails.root.join('db', 'seeds', '90_exams.rb'))
load(Rails.root.join('db', 'seeds', '100_exam_assignments.rb'))

# TheRole2 RBAC system seeds (requires User model to exist)
load(Rails.root.join('db', 'seeds', 'the_role2', '10_roles.rb'))
load(Rails.root.join('db', 'seeds', 'the_role2', '20_permissions_user.rb'))
load(Rails.root.join('db', 'seeds', 'the_role2', '30_permissions_student.rb'))
load(Rails.root.join('db', 'seeds', 'the_role2', '40_permissions_employee.rb'))
