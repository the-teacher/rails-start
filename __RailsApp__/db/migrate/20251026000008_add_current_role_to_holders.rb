class AddCurrentRoleToHolders < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :users, :the_role2_roles, column: :current_role_id
    add_foreign_key :profiles, :the_role2_roles, column: :current_role_id
    add_foreign_key :companies, :the_role2_roles, column: :current_role_id
    add_foreign_key :students, :the_role2_roles, column: :current_role_id
  end
end
