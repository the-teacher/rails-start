class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: true, foreign_key: true
      t.references :author, null: true, foreign_key: true

      t.text :body

      t.timestamps
    end
  end
end
