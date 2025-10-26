class CreateExamAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :exam_assignments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :exam, null: false, foreign_key: true
      t.datetime :assigned_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end

    add_index :exam_assignments, [ :student_id, :exam_id ], unique: true, name: 'idx_exam_assignments_student_exam'
  end
end
