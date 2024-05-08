class AddStatusToVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :variants, :status, :string, default: 'New', null: false
  end
end
