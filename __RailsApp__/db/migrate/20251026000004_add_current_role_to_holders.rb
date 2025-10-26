class AddCurrentRoleToHolders < ActiveRecord::Migration[8.1]
  def change
    # This migration adds the current_role_id column to models that use TheRole2::HasRoles
    # Uncomment and modify as needed for each model:

    # add_column :users, :current_role_id, :bigint, foreign_key: { to_table: :the_role2_roles }
    # add_index :users, :current_role_id

    # add_column :companies, :current_role_id, :bigint, foreign_key: { to_table: :the_role2_roles }
    # add_index :companies, :current_role_id

    # Example for a User model (uncomment if needed):
    # add_column :users, :current_role_id, :bigint
    # add_foreign_key :users, :the_role2_roles, column: :current_role_id
    # add_index :users, :current_role_id
  end
end
