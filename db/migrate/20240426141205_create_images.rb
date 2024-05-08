class CreateImages < ActiveRecord::Migration[7.1]
  def change
    create_table :images do |t|
      t.integer :uid
      t.string :title
      t.integer :position, default: 1, null: false
      t.references :variant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
