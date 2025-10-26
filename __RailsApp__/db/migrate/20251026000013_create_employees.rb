class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.timestamps
    end

    add_index :employees, [ :user_id, :department_id ], unique: true, name: 'idx_employees_user_department'
  end
end
