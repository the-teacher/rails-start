class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :student_id, null: false
      t.references :user, foreign_key: true
      t.string :grade
      t.bigint :current_role_id
      t.timestamps
    end

    add_index :students, :student_id, unique: true
    add_index :students, :current_role_id
    add_foreign_key :students, :the_role2_roles, column: :current_role_id
  end
end
