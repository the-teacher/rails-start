class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.bigint :current_role_id
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :current_role_id
    add_foreign_key :users, :the_role2_roles, column: :current_role_id
  end
end
