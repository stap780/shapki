class AddStatusToImports < ActiveRecord::Migration[7.1]
  def change
    add_column :imports, :status, :string, default: 'New', null: false
  end
end
