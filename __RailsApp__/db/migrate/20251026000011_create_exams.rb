class CreateExams < ActiveRecord::Migration[8.1]
  def change
    create_table :exams do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :scheduled_at
      t.integer :duration_minutes
      t.boolean :published, default: false
      t.timestamps
    end

    add_index :exams, :published
    add_index :exams, :scheduled_at
  end
end
