class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :status
      t.string :title
      t.integer :uid

      t.timestamps
    end
  end
end
