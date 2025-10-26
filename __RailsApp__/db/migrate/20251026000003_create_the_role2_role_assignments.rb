class CreateTheRole2RoleAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :the_role2_role_assignments do |t|
      t.references :the_role2_role, null: false, foreign_key: { to_table: :the_role2_roles }
      t.references :holder, polymorphic: true, null: false
      t.timestamps
    end

    add_index :the_role2_role_assignments,
      [ :the_role2_role_id, :holder_type, :holder_id ],
      unique: true,
      name: "idx_the_role2_role_assignments_role_holder"
  end
end
