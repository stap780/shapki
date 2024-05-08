class AddColumnBarcodeToVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :variants, :barcode, :string
  end
end
