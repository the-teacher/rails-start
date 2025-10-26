class CreateTheRole2Roles < ActiveRecord::Migration[8.1]
  def change
    create_table :the_role2_roles do |t|
      t.string  :name, null: false
      t.text    :description
      t.timestamps
    end

    add_index :the_role2_roles, :name, unique: true
  end
end
