class ChangeDefaultValueToStatusImports < ActiveRecord::Migration[7.1]
  def change
    change_column_default :imports, :status, from: "New", to: "new"
  end
end
