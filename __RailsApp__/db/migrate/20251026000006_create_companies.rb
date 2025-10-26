class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :current_role_id
      t.timestamps
    end

    add_index :companies, :current_role_id
    add_foreign_key :companies, :the_role2_roles, column: :current_role_id
  end
end
