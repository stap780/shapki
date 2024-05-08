class CreateVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :variants do |t|
      t.integer :uid
      t.string :sku
      t.integer :quantity, default: 0, null: false
      t.decimal :price, precision: 12, scale: 2, default: "0.0"
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
