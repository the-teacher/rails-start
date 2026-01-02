class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :author, null: true, foreign_key: true

      t.string :title
      t.text :body
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
