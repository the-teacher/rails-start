class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :bio
      t.bigint :current_role_id
      t.timestamps
    end

    add_index :profiles, :current_role_id
    add_foreign_key :profiles, :the_role2_roles, column: :current_role_id
  end
end
